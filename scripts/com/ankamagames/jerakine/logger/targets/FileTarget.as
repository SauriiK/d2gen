package com.ankamagames.jerakine.logger.targets
{
   import com.ankamagames.jerakine.logger.LogEvent;
   import com.ankamagames.jerakine.logger.LogLevel;
   import com.ankamagames.jerakine.logger.TextLogEvent;
   import com.ankamagames.jerakine.types.CustomSharedObject;
   import flash.events.Event;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.net.XMLSocket;
   
   public class FileTarget extends AbstractTarget implements ConfigurableLoggingTarget
   {
      
      private static var _socket:XMLSocket = new XMLSocket();
      
      private static var _history:Array = new Array();
      
      private static var _connecting:Boolean = false;
      
      protected static var _fileStream:FileStream = new FileStream();
       
      
      private var _name:String;
      
      public function FileTarget()
      {
         super();
         var date:Date = new Date();
         this._name = CustomSharedObject.getCustomSharedObjectDirectory() + "/logs/log_" + date.fullYear + "-" + date.month + "-" + date.day + "_" + date.hours + "h" + date.minutes + "m" + date.seconds + "s" + date.milliseconds + ".log";
         var file:File = new File(this._name);
         _fileStream.openAsync(file,FileMode.WRITE);
      }
      
      private static function send(level:int, message:String) : void
      {
         _fileStream.writeUTFBytes("[" + level + "] " + message);
      }
      
      private static function getKeyName(level:int) : String
      {
         switch(level)
         {
            case LogLevel.TRACE:
               return "trace";
            case LogLevel.DEBUG:
               return "debug";
            case LogLevel.INFO:
               return "info";
            case LogLevel.WARN:
               return "warning";
            case LogLevel.ERROR:
               return "error";
            case LogLevel.FATAL:
               return "fatal";
            default:
               return "severe";
         }
      }
      
      private static function onSocket(e:Event) : void
      {
         var o:* = null;
         _connecting = false;
         for each(o in _history)
         {
            send(o.level,o.message);
         }
         _history = new Array();
      }
      
      private static function onSocketError(e:Event) : void
      {
         _connecting = false;
      }
      
      override public function logEvent(event:LogEvent) : void
      {
         if(event is TextLogEvent)
         {
            send(event.level,event.message + "\n");
         }
      }
      
      public function configure(config:XML) : void
      {
      }
      
      public function get name() : String
      {
         return this._name;
      }
   }
}
