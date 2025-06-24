/* 
manufacturer
"NVIDIA Corporation"
model
"NVIDIA GeForce GTX 1650"
supportsCuda
true
supportsVulkan
true
vramMb

3938*/

import {
    Card,
    CardContent,
    CardDescription,
    CardHeader,
    CardTitle,
} from "@/components/ui/card"

export interface GpuInfoProps{
    gpuTime?:number
    manufacturer?:string
    model?:string
    supportsCuda?:boolean
    supportsVulkan?:boolean
    vramMb?:number
}

export function GpuInfo({
  gpuTime = 0,
  manufacturer,
  model,
  supportsCuda,
  supportsVulkan,
  vramMb = 0
}:GpuInfoProps){

    return(
        <Card className="w-full max-w-md">
            <CardHeader>
                <CardTitle>{model || "GPU Information"}</CardTitle>
                <CardDescription>{manufacturer || "N/A"}</CardDescription>
            </CardHeader>
            <CardContent className="flex items-center gap-6">
                <div className="flex h-28 w-28 flex-shrink-0 items-center justify-center rounded-full border-4 border-primary bg-primary/10 p-2">
                    <div className="text-center">
                        <p className="text-sm font-bold text-primary">
                            {gpuTime}
                        </p>
                        <p className="text-xs text-muted-foreground">GPU Time</p>
                    </div>
                </div>
                <div className="grid flex-1 gap-1">
                    <div className="flex justify-between text-sm">
                        <span className="text-muted-foreground">VRAM:</span>
                        <span className="font-semibold">
                            {(vramMb / 1024).toFixed(2)} GB
                        </span>
                    </div>
                    <div className="flex justify-between text-sm">
                        <span className="text-muted-foreground">CUDA Support:</span>
                        <span className="font-semibold">{supportsCuda ? "Yes" : "No"}</span>
                    </div>
                    <div className="flex justify-between text-sm">
                        <span className="text-muted-foreground">Vulkan Support:</span>
                        <span className="font-semibold">{supportsVulkan ? "Yes" : "No"}</span>
                    </div>
                </div>
            </CardContent>
        </Card>
    )
}