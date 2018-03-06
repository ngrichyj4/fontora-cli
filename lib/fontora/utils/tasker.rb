module Fontora
 module Utils
  module Tasker
   # => Add method execution to queue
   def task *args
    pending_tasks.concat args
   end

   def pending_tasks
    @pending_tasks ||= []
   end

   # => Run all methods in background and get their results
   def wait_until_completion!
    pending_tasks.map do |action| 
     Celluloid::Future.new do 
      send(action) if self.respond_to? action 
     end 
    end.map(&:value) 
    pending_tasks.clear
   end

  end
 end
end