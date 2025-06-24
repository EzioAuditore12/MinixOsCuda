import { useEffect } from "react";
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

function TerminalRenderer() {
  useEffect(() => {
    import("./Terminal");
  }, []);

  return <div id="terminal" className="w-full h-full" />;
}

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


export default function App(){
  return(
     <ThemeProvider defaultTheme="dark" storageKey="vite-ui-theme">
      <CustomTitleBar/>
     <div className="flex flex-col gap-y-3 mt-[40px] relative"> 
     <TerminalRenderer/>
     <Button
     onClick={()=>{
      logSystemInfo()
     }}
     >Hello</Button>
     <ModeToggle/>
    </div>
    </ThemeProvider>
  )
}