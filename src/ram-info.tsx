/* */

export interface RamSizeProps{
manufacturer?:string
sizeMb?:number
}

export function RamSizeInfo({
 sizeMb
}:RamSizeProps){

    return(
        <div>
            <h1>{sizeMb}</h1>
        </div>
    )
}