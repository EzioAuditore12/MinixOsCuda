/* CPU Info: {manufacturer: 'AuthenticAMD', model: 'AMD Ryzen 5 5600H with Radeon Graphics', maxFrequency: 3301, threads: 12}*/
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"

export interface CpuInfoProps{
  cpuTime?:number
  manufacturer?:string
  model?:string
  maxFrequency?:number
  threads?:number
  sizeMb?:number
}

export function CpuInfo({
  cpuTime = 0,
  manufacturer,
  model,
  maxFrequency,
  threads,
  sizeMb
}:CpuInfoProps){

    return(
        <Card className="w-full max-w-md">
            <CardHeader>
                <CardTitle>{model || "CPU Information"}</CardTitle>
                <CardDescription>{manufacturer || "N/A"}</CardDescription>
            </CardHeader>
            <CardContent className="flex items-center gap-6">
                <div className="flex h-28 w-28 flex-shrink-0 items-center justify-center rounded-full border-4 border-primary bg-primary/10 ">
                    <div className="text-center">
                        <p className="text-sm font-bold text-primary">
                            {cpuTime}
                        </p>
                        <p className="text-xs text-muted-foreground">CPU Time</p>
                    </div>
                </div>
                <div className="grid flex-1 gap-1">
                    <div className="flex justify-between text-sm">
                        <span className="text-muted-foreground">Max Speed:</span>
                        <span className="font-semibold">
                            {maxFrequency ? `${(maxFrequency / 1000).toFixed(2)} GHz` : "N/A"}
                        </span>
                    </div>
                    <div className="flex justify-between text-sm">
                        <span className="text-muted-foreground">Threads:</span>
                        <span className="font-semibold">{threads || "N/A"}</span>
                        <span className="text-muted-foreground">Ram Size:</span>
                        <span className="font-semibold">{sizeMb || "N/A"}</span>
                    </div>
                </div>
            </CardContent>
        </Card>
    )
}