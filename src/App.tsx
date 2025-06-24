import { useEffect } from "react";
import { Button } from "./components/ui/button";
import { ThemeProvider } from "@/components/theme-provider"
import { ModeToggle } from "./components/theme-toggle";
import CustomTitleBar from "./custom-window";

function TerminalRenderer() {
  useEffect(() => {
    import("./Terminal");
  }, []);

  return <div id="terminal" className="w-[500px]" />;
}


export default function App(){
  return(
     <ThemeProvider defaultTheme="dark" storageKey="vite-ui-theme">
      <CustomTitleBar/>
     <div className="flex flex-col gap-y-3 mt-[40px] relative"> 
     <TerminalRenderer/>
     <Button>Hello</Button>
     <ModeToggle/>
    </div>
    </ThemeProvider>
  )
}