package com.ankamagames.dofus.logic.connection.frames
{
   import com.ankamagames.berilia.managers.UiModuleManager;
   import com.ankamagames.dofus.BuildInfos;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.kernel.PanicMessages;
   import com.ankamagames.dofus.kernel.net.ConnectionsHandler;
   import com.ankamagames.dofus.network.Metadata;
   import com.ankamagames.dofus.network.enums.BuildTypeEnum;
   import com.ankamagames.dofus.network.messages.common.basic.BasicPingMessage;
   import com.ankamagames.dofus.network.messages.handshake.ProtocolRequired;
   import com.ankamagames.jerakine.data.I18n;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.messages.ConnectedMessage;
   import com.ankamagames.jerakine.messages.Frame;
   import com.ankamagames.jerakine.messages.Message;
   import com.ankamagames.jerakine.network.INetworkMessage;
   import com.ankamagames.jerakine.types.enums.Priority;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getQualifiedClassName;
   
   public class HandshakeFrame implements Frame
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(HandshakeFrame));
       
      
      private var _timeOutTimer:Timer;
      
      public function HandshakeFrame()
      {
         super();
      }
      
      public function get priority() : int
      {
         return Priority.HIGHEST;
      }
      
      public function pushed() : Boolean
      {
         ConnectionsHandler.hasReceivedNetworkMsg = false;
         return true;
      }
      
      public function process(msg:Message) : Boolean
      {
         var prmsg:* = null;
         var commonMod:* = null;
         ConnectionsHandler.hasReceivedMsg = true;
         if(msg is INetworkMessage)
         {
            ConnectionsHandler.hasReceivedNetworkMsg = true;
            if(this._timeOutTimer)
            {
               this._timeOutTimer.stop();
            }
         }
         switch(true)
         {
            case msg is ProtocolRequired:
               prmsg = msg as ProtocolRequired;
               if(prmsg.requiredVersion > Metadata.PROTOCOL_BUILD)
               {
                  _log.fatal("Current protocol build is " + Metadata.PROTOCOL_BUILD + ", required build is " + prmsg.requiredVersion + ".");
                  Kernel.panic(PanicMessages.PROTOCOL_TOO_OLD,[Metadata.PROTOCOL_BUILD,prmsg.requiredVersion]);
               }
               if(prmsg.currentVersion < Metadata.PROTOCOL_REQUIRED_BUILD)
               {
                  _log.fatal("Current protocol build (" + Metadata.PROTOCOL_BUILD + ") is too new for the server version (" + prmsg.currentVersion + ").");
                  if(BuildInfos.BUILD_TYPE >= BuildTypeEnum.TESTING)
                  {
                     commonMod = UiModuleManager.getInstance().getModule("Ankama_Common").mainClass;
                     commonMod.openPopup(I18n.getUiText("ui.popup.warning"),I18n.getUiText("ui.popup.protocolError",[Metadata.PROTOCOL_BUILD,prmsg.currentVersion]),[I18n.getUiText("ui.common.ok")]);
                  }
               }
               Kernel.getWorker().removeFrame(this);
               return true;
            case msg is ConnectedMessage:
               this._timeOutTimer = new Timer(3000,1);
               this._timeOutTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimeOut);
               this._timeOutTimer.start();
               return true;
            default:
               return false;
         }
      }
      
      public function onTimeOut(e:TimerEvent) : void
      {
         var pingMsg:BasicPingMessage = new BasicPingMessage();
         pingMsg.initBasicPingMessage(true);
         ConnectionsHandler.getConnection().send(pingMsg);
      }
      
      public function pulled() : Boolean
      {
         if(this._timeOutTimer)
         {
            this._timeOutTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimeOut);
         }
         return true;
      }
   }
}
