#include <chrono>
#include <climits>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <cuda_runtime.h>
#include <ostream>
#include <string>
#include <sstream>
#include <vector>
#include <algorithm>

#define BLOCK_SIZE 256

__device__ int dev_time;
__device__ int dev_completed;

struct Process {
    int id;
    int arrival;
    int burst;
    int priority;
    int completion;
    int remaining;
    bool completed;
};

int get_process_size(std::string file_name) {
    std::string line;
    int process_count = 0;
    std::ifstream t_file(file_name);

    if (std::getline(t_file, line)) {
        std::istringstream iss(line);
        int value;
        process_count = 0;

        while(iss >> value) {
            process_count++;
        }
    }

    return process_count;
}

void file_reader_assigner(std::string process_file, int *at_array, int *bt_array, int *pt_array) {
    std::ifstream p_file(process_file);
    std::string line;
    int process_count = 0;

    if (std::getline(p_file, line)) {
        std::istringstream iss(line);
        int value;
        process_count = 0;

        while(iss >> value) {
            at_array[process_count++] = value;
        }
    }
    
    if (std::getline(p_file, line)) {
        std::istringstream iss(line);
        int value;
        int i = 0;
        while((iss >> value) && i < process_count) {
            bt_array[i++] = value;
        }
    }

    if (std::getline(p_file, line)) {
        std::istringstream iss(line);
        int value;
        int i = 0;
        while((iss >> value) && i < process_count) {
            pt_array[i++] = value;
        }
    }
    
    std::cout << "File size: " << process_count << std::endl;
}

// CPU Scheduler Function
void cpu_priority_scheduler(int N, int *arrival, int *burst, int *priority, 
                          int *is_completed, int *completion_time, int *remaining) {

    for (int i = 0; i < N; i++) {
        remaining[i] = burst[i];
        is_completed[i] = 0;
        completion_time[i] = 0;
    }

    int current_time = 0;
    int completed = 0;

    while (completed < N) {

        int highest_priority = INT_MAX;
        int selected_process = -1;

        for (int i = 0; i < N; i++) {
            if (!is_completed[i] && arrival[i] <= current_time && remaining[i] > 0) {
                if (priority[i] < highest_priority) {
                    highest_priority = priority[i];
                    selected_process = i;
                }
            }
        }

        if (selected_process == -1) {

            current_time++;
        } else {

            remaining[selected_process]--;
            
            // If process completes
            if (remaining[selected_process] == 0) {
                is_completed[selected_process] = 1;
                completion_time[selected_process] = current_time + 1;
                completed++;
            }
            
            current_time++;
        }
    }
}

// GPU Scheduler Kernel
__global__ void scheduler_kernel(int *arrival, int *remaining, int *priority, 
                                int *is_completed, int *completion_time, int N) {
    __shared__ unsigned int s_best_packed;  
    int tid = blockIdx.x * blockDim.x + threadIdx.x;

    while (true) {
        // reset block's best
        if (threadIdx.x == 0) s_best_packed = 0xFFFFFFFFu;
        __syncthreads();

        int cur_time = atomicAdd(&dev_time, 0);

        if (tid < N && !is_completed[tid]
            && arrival[tid] <= cur_time
            && remaining[tid] > 0) {
            unsigned int pack = ((unsigned int)priority[tid] << 16) | (unsigned int)tid;
            atomicMin(&s_best_packed, pack);
        }
        __syncthreads();

        if (threadIdx.x == 0) {
            unsigned int best = s_best_packed;
            if (best != 0xFFFFFFFFu) {
                int idx = best & 0xFFFF;
               
                int prev = atomicSub(&remaining[idx], 1);
                if (prev == 1) {
                    is_completed[idx] = 1;
                    completion_time[idx] = cur_time + 1;
                    atomicAdd(&dev_completed, 1);
                }
            }
            // Go to next time unit (like t0 -> t1)
            atomicAdd(&dev_time, 1);
        }
        __syncthreads();
       
        if (atomicAdd(&dev_completed, 0) >= N) break;
    }
}


void display_results(int N, int *arrival, int *burst, int *priority, 
                   int *is_completed, int *completion_time, int *remaining, int final_time, int final_done, bool display_processes) {
    std::cout << "Simulated time steps: " << final_time << ", Completed: " << final_done << "/" << N << "\n";

    if (!display_processes) {
        return; 
    }

    // Displaying the output of Initial process (read from file)
    std::cout << "Processes result: \n";
    
    std::cout << "\nPid\tAT\tBT\tPr\tComp\tRemaining\n";
    for(int i = 0; i < N; i++) {
        std::cout << i << "\t" << arrival[i] << "\t" << burst[i] << "\t" << priority[i] 
                  << "\t" << (is_completed[i] ? "Yes" : "No") << "\t" << remaining[i] << "\n";
    }

    std::vector<Process> processes(N);
    for (int i = 0; i < N; i++) {
        processes[i] = {
            i,            
            arrival[i],       
            burst[i],        
            priority[i],       
            completion_time[i],
            remaining[i],  
            (bool)is_completed[i] 
        };
    }
    
    // Sort processes by completion time
    std::sort(processes.begin(), processes.end(), 
              [](const Process& a, const Process& b) {
                  if (a.completed && b.completed) {
                      return a.completion < b.completion;
                  }
                  return a.completed > b.completed;
              });
    
    
    std::cout << "\nProcesses in scheduled order:\n";
    std::cout << "Pid\tAT\tBT\tPr\tCT\tTAT\tWT\n";
    for (const auto& p : processes) {
        if (p.completed) {
            int turnaround = p.completion - p.arrival;
            int waiting = turnaround - p.burst;
            std::cout << p.id << "\t" << p.arrival << "\t" << p.burst << "\t" 
                      << p.priority << "\t" << p.completion << "\t" 
                      << turnaround << "\t" << waiting << "\n";
        }
    }
}

int main(int argc, char *argv[]) {
    if (argc < 3) {
        std::cerr << "Usage: " << argv[0] << " [-cpu|-gpu] <filename> [-display|-nodisplay]" << std::endl;
        return 1;
    }
    
    std::string mode = argv[1];
    std::string filename = argv[2];
    
    // Set default display mode
    bool display_processes = false;
    
    // Check for display flag
    if (argc >= 4) {
        std::string display_flag = argv[3];
        if (display_flag == "-display") {
            display_processes = true;
        } else if (display_flag == "-nodisplay") {
            display_processes = false;
        } else {
            std::cerr << "Invalid display flag. Use -display or -nodisplay." << std::endl;
            return 1;
        }
    }
    
    int N = get_process_size(filename);
    
    int *h_arrival = new int[N];
    int *h_burst = new int[N];
    int *h_prior = new int[N];
    int *h_completed = new int[N];
    int *h_completion = new int[N];
    int *h_remaining = new int[N];
    
    file_reader_assigner(filename, h_arrival, h_burst, h_prior);
    
    if (mode == "-cpu") {
        // CPU Mode
        std::cout << "Running CPU scheduler...\n";
        auto t0 = std::chrono::high_resolution_clock::now();
        cpu_priority_scheduler(N, h_arrival, h_burst, h_prior, h_completed, h_completion, h_remaining);
        auto t1 = std::chrono::high_resolution_clock::now();
        
        double cput = std::chrono::duration<double>(t1-t0).count();
        std::cout << "CPU time: " << cput << " s\n";
        
        // Count completed processes
        int final_done = 0;
        for (int i = 0; i < N; i++) {
            if (h_completed[i]) final_done++;
        }
        
        int final_time = 0;
        for (int i = 0; i < N; i++) {
            if (h_completed[i] && h_completion[i] > final_time) {
                final_time = h_completion[i];
            }
        }
        
        display_results(N, h_arrival, h_burst, h_prior, h_completed, h_completion, h_remaining, final_time, final_done, display_processes);
    }
    else if (mode == "-gpu") {
        // GPU Mode
        int *d_arr, *d_rem, *d_pri, *d_done, *d_completion;
        cudaMalloc(&d_arr, N*sizeof(int));
        cudaMalloc(&d_rem, N*sizeof(int));
        cudaMalloc(&d_pri, N*sizeof(int));
        cudaMalloc(&d_done, N*sizeof(int));
        cudaMalloc(&d_completion, N*sizeof(int));
        
        cudaMemcpy(d_arr, h_arrival, N*sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_pri, h_prior, N*sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_rem, h_burst, N*sizeof(int), cudaMemcpyHostToDevice);
        cudaMemset(d_done, 0, N*sizeof(int));
        cudaMemset(d_completion, 0, N*sizeof(int));
        
        int zero = 0;
        cudaMemcpyToSymbol(dev_time, &zero, sizeof(int));
        cudaMemcpyToSymbol(dev_completed, &zero, sizeof(int));
        
        dim3 block(BLOCK_SIZE), grid((N+BLOCK_SIZE-1)/BLOCK_SIZE);
        
        std::cout << "Running GPU scheduler...\n";
        auto t0 = std::chrono::high_resolution_clock::now();
        scheduler_kernel<<<grid,block>>>(d_arr, d_rem, d_pri, d_done, d_completion, N);
        cudaDeviceSynchronize();
        auto t1 = std::chrono::high_resolution_clock::now();
        
        double gput = std::chrono::duration<double>(t1-t0).count();
        std::cout << "GPU time: " << gput << " s\n";
        
        int final_time = 0, final_done = 0;
        cudaMemcpyFromSymbol(&final_time, dev_time, sizeof(int));
        cudaMemcpyFromSymbol(&final_done, dev_completed, sizeof(int));
        
        // Copy device memory back to host only if we need to display results
        if (display_processes) {
            cudaMemcpy(h_arrival, d_arr, N*sizeof(int), cudaMemcpyDeviceToHost);
            cudaMemcpy(h_prior, d_pri, N*sizeof(int), cudaMemcpyDeviceToHost);
            cudaMemcpy(h_completed, d_done, N*sizeof(int), cudaMemcpyDeviceToHost);
            cudaMemcpy(h_remaining, d_rem, N*sizeof(int), cudaMemcpyDeviceToHost);
            cudaMemcpy(h_completion, d_completion, N*sizeof(int), cudaMemcpyDeviceToHost);
        }
        
        display_results(N, h_arrival, h_burst, h_prior, h_completed, h_completion, h_remaining, final_time, final_done, display_processes);
        
        // Free device memory
        cudaFree(d_arr);
        cudaFree(d_rem);
        cudaFree(d_pri);
        cudaFree(d_done);
        cudaFree(d_completion);
    }
    else {
        std::cerr << "Invalid mode. Use -cpu or -gpu." << std::endl;
        return 1;
    }
    
    // Free host memory
    delete[] h_arrival;
    delete[] h_burst;
    delete[] h_prior;
    delete[] h_completed;
    delete[] h_completion;
    delete[] h_remaining;
    
    return 0;
}