import { X, Expand, Minimize2, Shrink } from 'lucide-react';
import { getCurrentWindow } from '@tauri-apps/api/window';
import { useState, useEffect } from 'react';
import { ModeToggle } from './components/theme-toggle';

export default function CustomTitleBar() {
    const [isMaximized, setIsMaximized] = useState(false);
    const appWindow=getCurrentWindow()

    useEffect(() => {
        const updateMaximizeState = async () => {
            setIsMaximized(await appWindow.isMaximized());
        };

        // Set initial state and listen for changes
        updateMaximizeState();
        const unlisten = appWindow.onResized(updateMaximizeState);

        return () => {
            // Cleanup listener
            unlisten.then(f => f());
        };
    }, []);

    return (
        <>
            <div
                data-tauri-drag-region
                className="fixed top-0 left-0 right-0 h-10 bg-gray-100 dark:bg-zinc-900 flex justify-center items-center border-b border-gray-200 dark:border-zinc-800 z-[1000]"
            >
                <ModeToggle className='absolute left-0'/>
                <p className="text-sm select-none text-cyan-500">CPU and GPU Process Schedular Operating</p>
                <div className="absolute right-0 flex items-center gap-x-1 px-2">
                    <button
                        className='p-1.5 rounded-md hover:bg-gray-200 dark:hover:bg-zinc-700'
                        onClick={() => appWindow.minimize()}
                    >
                        <Minimize2 size={16} />
                    </button>
                    <button
                        className='p-1.5 rounded-md hover:bg-gray-200 dark:hover:bg-zinc-700'
                        onClick={() => appWindow.toggleMaximize()}
                    >
                        {isMaximized ? <Shrink size={16} /> : <Expand size={16} />}
                    </button>
                    <button
                        className='p-1.5 rounded-md hover:bg-red-500 hover:text-white dark:hover:bg-red-600'
                        onClick={() => appWindow.close()}
                    >
                        <X size={16} />
                    </button>
                </div>
            </div>
        </>
    );
}