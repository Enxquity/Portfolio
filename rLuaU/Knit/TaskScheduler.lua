local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local TaskScheduler = Knit.CreateController { 
    Name = "TaskScheduler"
}

type Scheduler = {
    Schduled: table,

    ScheduleFor: (
        self: table,
        Time: number, 
        Func: () -> ()
    ) -> (Promise),

    ScheduleForAsync: (
        self: table,
        Time: number, 
        Func: () -> ()
    ) -> (Promise)
}

type Promise = {
    AndThen: (
        self: table,
         any
    ) -> ()
}

function TaskScheduler:Promise(Resolve)
    return {
        AndThen = function(self, Func, ...)
            return TaskScheduler:Promise(
                Func(...)
            )
        end
    } :: Promise
end

function TaskScheduler:New(Func, Time)
    local Scheduler = {
        Schduled = {};

        ScheduleFor = function(self, Time, Func)
            task.delay(Time, Func)
            return TaskScheduler:Promise()
        end;

        ScheduleForAsync = function(self, Time, Func)
            local Clock = os.time()

            repeat 
                task.wait() 
            until os.time() - Clock >= Time

            Func()
            return TaskScheduler:Promise()
        end
    } :: Scheduler

    return Scheduler
end

function TaskScheduler:KnitStart()
    
end


function TaskScheduler:KnitInit()
    
end


return TaskScheduler
