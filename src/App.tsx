import { useEffect, useState } from "react";
import { Button } from "./components/ui/button";
import { ThemeProvider } from "@/components/theme-provider"
import { ModeToggle } from "./components/theme-toggle";
import CustomTitleBar from "./custom-window";
import {
  getCpuInfo,
  getRamInfo,
  getGpuInfo,
  getOsInfo,
} from "tauri-plugin-hwinfo";
import { CpuInfo, type CpuInfoProps } from "./cpu-info";
import { RamSizeInfo,type RamSizeProps } from "./ram-info";
import { GpuInfo,type GpuInfoProps } from "./gpu-info";
import { gpu_time,cpu_time } from "./stats/result";

function TerminalRenderer() {
  useEffect(() => {
    import("./Terminal");
  }, []);

  return <div id="terminal" className="w-full h-full" />;
}

/* System Info Api
async function logSystemInfo() {
  const cpu = await getCpuInfo();
  const ram = await getRamInfo();
  const gpu = await getGpuInfo();
  const os = await getOsInfo();

  console.log("CPU Info:", cpu);
  console.log("RAM Info:", ram);
  console.log("GPU Info:", gpu);
  console.log("OS Info:", os);
}
*/

export default function App(){
  const [cpuInfo, setCpuInfo] = useState<CpuInfoProps>({});
  const [ramSizeInfo,setRamSizeInfo]=useState<RamSizeProps>({})
  const [gpuInfo,setGpuInfo]=useState<GpuInfoProps>({})
  useEffect(() => {
    const fetchCpuInfo = async () => {
      const cpu = await getCpuInfo();
      setCpuInfo(cpu);
      const ram= await getRamInfo()
      setRamSizeInfo(ram)
      const gpu=await getGpuInfo()
      setGpuInfo(gpu)
    };
    fetchCpuInfo();
  }, []);

  return(
     <ThemeProvider defaultTheme="dark" storageKey="vite-ui-theme">
      <CustomTitleBar/>
     <div className="grid grid-cols-2 place-content-center gap-y-3 mt-[40px] relative"> 
     <TerminalRenderer/>
     <div className="flex justify-center items-center flex-col">
     <CpuInfo
     cpuTime={cpu_time}
     sizeMb={ramSizeInfo.sizeMb}
     manufacturer={cpuInfo.manufacturer}
     model={cpuInfo.model}
     maxFrequency={cpuInfo.maxFrequency}
     threads={cpuInfo.threads}
     />
     <RamSizeInfo
     sizeMb={ramSizeInfo.sizeMb}
     />
     <GpuInfo
     gpuTime={gpu_time}
     manufacturer={gpuInfo.manufacturer}
     model={gpuInfo.model}
     supportsCuda={gpuInfo.supportsCuda}
     supportsVulkan={gpuInfo.supportsVulkan}
     vramMb={gpuInfo.vramMb}
     />
     </div>
    </div>
    </ThemeProvider>
  )
}