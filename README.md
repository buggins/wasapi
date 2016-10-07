# wasapi
D bindings of Windows Core Audio interfaces: Core Audio interfaces: MMDevice, WASAPI, EndpointVolume API


Manual translation of Windows Core Audio .h files.



        // Useful helper functions: setHighThreadPriority && restoreThreadPriority.

        // use setHighThreadPriority to boost current thread priority
        void * hTask = setHighThreadPriority();

        // play audio

        // restore normal priority
        restoreThreadPriority(hTask);
