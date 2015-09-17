# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "thread_safe"

class LogStash::Filters::LookupTable < LogStash::Filters::Base

  config_name "lookuptable"
  plugin_status 1

  config :cache, :validate => :hash, :require => true
  
  public
  def register
    # This filter needs to keep state.
    @_index_cache = ThreadSafe::Cache.new  
  end # def register

  public
  def filter(event)
    return unless filter?(event)
    
    @cache.each do |source, target|
      next unless event.include?(source)
    
      if event.include?(target)
        @_index_cache.put_if_absent(event[source], event[target])
      else
        event[target] = @_index_cache[event[source]]
      end
    end
   
    filter_matched(event)
  end

end # class LogStash::Filters::LookupTable
  
  

  
  