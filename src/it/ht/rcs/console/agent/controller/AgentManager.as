package it.ht.rcs.console.agent.controller
{
  import it.ht.rcs.console.DB;
  import it.ht.rcs.console.DefaultConfigBuilder;
  import it.ht.rcs.console.ObjectUtils;
  import it.ht.rcs.console.agent.model.Agent;
  import it.ht.rcs.console.agent.model.Config;
  import it.ht.rcs.console.controller.ItemManager;
  import it.ht.rcs.console.operation.model.Operation;
  import it.ht.rcs.console.target.model.Target;
  
  import mx.collections.ArrayCollection;
  import mx.rpc.events.ResultEvent;
  
  public class AgentManager extends ItemManager
  {
    
    public function AgentManager() { super(Agent); }
    
    private static var _instance:AgentManager = new AgentManager();
    public static function get instance():AgentManager { return _instance; }
    
    override public function refresh():void
    {
      super.refresh();
      DB.instance.agent.all(onResult);
    }
    
    private function onResult(e:ResultEvent):void
    {
      clear();
      for each (var item:* in e.result.source)
        addItem(item);
      dispatchDataLoadedEvent();
    }
    
    override protected function onItemRemove(item:*):void
    {
      DB.instance.agent.destroy(item._id);
    }
    
    override protected function onItemUpdate(event:*):void
    {
      var property:Object = new Object();
      property[event.property] = event.newValue is ArrayCollection ? event.newValue.source : event.newValue;
      DB.instance.agent.update(event.source, property);
    }
    
    public function addConfig(agent:Agent, config:String, callback:Function=null):void
    {
      DB.instance.agent.add_config(agent, config, function(e:ResultEvent):void {
        if (callback != null)
          callback(e.result);
      });
    }
    
    public function addFactory(f:Agent, o:Operation, t:Target, callback:Function):void
    {
      DB.instance.agent.create(ObjectUtils.toHash(f), o, t, function(e1:ResultEvent):void {
        var factory:Agent = e1.result as Agent;
        var defaultConfig:Object = DefaultConfigBuilder.getDefaultConfig(factory);
        AgentManager.instance.addConfig(factory, JSON.stringify(defaultConfig), function(c:Config):void {
          addItem(factory);
          callback(factory);
        });
      });
    }
    
    public function show(_id:String, callback:Function):void
    {
      DB.instance.agent.show(_id, callback);
    }
    
  }
  
}