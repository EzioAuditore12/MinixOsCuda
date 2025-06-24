#include <climits>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <cuda_runtime.h>
#include <ostream>
#include <string>



void process_file_setter(int n, int arrival_size, int burst_size, int priority_size, std::string path){
    // FILE *process_file = fopen("process_file.txt", "w");
    std::ofstream process_file(path);

    for(int i=0;i<n;i++) {
        process_file << (rand() % arrival_size) + 1 << " ";
    }
    process_file << std::endl;

    for(int i=0;i<n;i++) {
        process_file << (rand() % burst_size ) + 1 << " ";
    }
    process_file << std::endl;
    for(int i=0;i<n;i++) {
        process_file << (rand() % priority_size) + 1 << " ";
    }
     process_file << std::endl;
}


int main(int argc, char *argv[]){

    // std::cout<<"Lenght: "<<argc<<std::endl;

    // std::cout<<argv[1]<<" "<<argv[2]<<std::endl;

    // if(argv[1] == "-d"){
    //     // display the output
    // }

    // if(argv[1] == "-p"){
    //     // send the performance (do bigger)
    // }
    std::string path = argv[1];

    // std::string windows_desktop = "/mnt/c/Users/Manas Bisht/Desktop/";
    // std::string final_path = windows_desktop + path;
    std::string final_path = path;
    
    int process_num = atoi(argv[2]);

    std::cout<<"Final path: "<<final_path<<std::endl;
    process_file_setter(process_num, 100, 40, 20, final_path);
    
}