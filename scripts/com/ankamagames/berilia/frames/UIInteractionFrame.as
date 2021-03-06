package com.ankamagames.berilia.frames
{
   import com.ankamagames.berilia.Berilia;
   import com.ankamagames.berilia.UIComponent;
   import com.ankamagames.berilia.components.Grid;
   import com.ankamagames.berilia.components.Input;
   import com.ankamagames.berilia.components.messages.BrowserDomChange;
   import com.ankamagames.berilia.components.messages.BrowserDomReady;
   import com.ankamagames.berilia.components.messages.BrowserSessionTimeout;
   import com.ankamagames.berilia.components.messages.ChangeMessage;
   import com.ankamagames.berilia.components.messages.ColorChangeMessage;
   import com.ankamagames.berilia.components.messages.ComponentMessage;
   import com.ankamagames.berilia.components.messages.ComponentReadyMessage;
   import com.ankamagames.berilia.components.messages.CreateTabMessage;
   import com.ankamagames.berilia.components.messages.DeleteTabMessage;
   import com.ankamagames.berilia.components.messages.DropMessage;
   import com.ankamagames.berilia.components.messages.EntityReadyMessage;
   import com.ankamagames.berilia.components.messages.ItemRightClickMessage;
   import com.ankamagames.berilia.components.messages.ItemRollOutMessage;
   import com.ankamagames.berilia.components.messages.ItemRollOverMessage;
   import com.ankamagames.berilia.components.messages.MapElementRightClickMessage;
   import com.ankamagames.berilia.components.messages.MapElementRollOutMessage;
   import com.ankamagames.berilia.components.messages.MapElementRollOverMessage;
   import com.ankamagames.berilia.components.messages.MapMoveMessage;
   import com.ankamagames.berilia.components.messages.MapRollOutMessage;
   import com.ankamagames.berilia.components.messages.MapRollOverMessage;
   import com.ankamagames.berilia.components.messages.RenameTabMessage;
   import com.ankamagames.berilia.components.messages.SelectEmptyItemMessage;
   import com.ankamagames.berilia.components.messages.SelectItemMessage;
   import com.ankamagames.berilia.components.messages.TextClickMessage;
   import com.ankamagames.berilia.components.messages.TextureLoadFailMessage;
   import com.ankamagames.berilia.components.messages.TextureReadyMessage;
   import com.ankamagames.berilia.components.messages.VideoBufferChangeMessage;
   import com.ankamagames.berilia.components.messages.VideoConnectFailedMessage;
   import com.ankamagames.berilia.components.messages.VideoConnectSuccessMessage;
   import com.ankamagames.berilia.enums.EventEnums;
   import com.ankamagames.berilia.enums.SelectMethodEnum;
   import com.ankamagames.berilia.managers.KernelEventsManager;
   import com.ankamagames.berilia.managers.SecureCenter;
   import com.ankamagames.berilia.managers.UIEventManager;
   import com.ankamagames.berilia.managers.UiSoundManager;
   import com.ankamagames.berilia.types.event.InstanceEvent;
   import com.ankamagames.berilia.types.graphic.GraphicContainer;
   import com.ankamagames.berilia.types.graphic.UiRootContainer;
   import com.ankamagames.berilia.utils.BeriliaHookList;
   import com.ankamagames.jerakine.handlers.FocusHandler;
   import com.ankamagames.jerakine.handlers.messages.Action;
   import com.ankamagames.jerakine.handlers.messages.FocusChangeMessage;
   import com.ankamagames.jerakine.handlers.messages.HumanInputMessage;
   import com.ankamagames.jerakine.handlers.messages.keyboard.KeyboardKeyDownMessage;
   import com.ankamagames.jerakine.handlers.messages.keyboard.KeyboardKeyUpMessage;
   import com.ankamagames.jerakine.handlers.messages.mouse.MouseClickMessage;
   import com.ankamagames.jerakine.handlers.messages.mouse.MouseDoubleClickMessage;
   import com.ankamagames.jerakine.handlers.messages.mouse.MouseMiddleClickMessage;
   import com.ankamagames.jerakine.handlers.messages.mouse.MouseWheelMessage;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.logger.ModuleLogger;
   import com.ankamagames.jerakine.managers.ErrorManager;
   import com.ankamagames.jerakine.messages.Frame;
   import com.ankamagames.jerakine.messages.Message;
   import com.ankamagames.jerakine.pools.GenericPool;
   import com.ankamagames.jerakine.types.enums.Priority;
   import com.ankamagames.jerakine.utils.display.StageShareManager;
   import com.ankamagames.jerakine.utils.misc.CallWithParameters;
   import flash.display.DisplayObject;
   import flash.display.InteractiveObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   
   public class UIInteractionFrame implements Frame
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(UIInteractionFrame));
       
      
      private var hierarchy:Array;
      
      private var currentDo:DisplayObject;
      
      private var _isProcessingDirectInteraction:Boolean;
      
      private var _warning:InputWarning;
      
      private var _lastTs:uint = 0;
      
      private var _lastW:uint;
      
      private var _lastH:uint;
      
      private var _lastWTs:uint = 0;
      
      private var _lastWW:uint;
      
      private var _lastWH:uint;
      
      public function UIInteractionFrame()
      {
         super();
      }
      
      public function get priority() : int
      {
         return Priority.HIGHEST;
      }
      
      public function get isProcessingDirectInteraction() : Boolean
      {
         return this._isProcessingDirectInteraction;
      }
      
      public function process(msg:Message) : Boolean
      {
         var fcmsg:* = null;
         var uiRootCtr:* = null;
         var input:* = null;
         var himsg:* = null;
         var onlyGrid:Boolean = false;
         var isGrid:* = false;
         var gridInstance:* = null;
         var dispatched:Boolean = false;
         var comsg:* = null;
         var inputPos:* = null;
         var kkdmsg:* = null;
         var kkumsg:* = null;
         var uic:* = null;
         var res:Boolean = false;
         var newMsg:* = null;
         var uic3:* = null;
         var uic4:* = null;
         var act2:* = null;
         var targetFct:* = null;
         var ie2:* = null;
         var args:* = null;
         var gcui:* = null;
         this._isProcessingDirectInteraction = false;
         this.currentDo = null;
         loop9:
         switch(true)
         {
            case msg is FocusChangeMessage:
               fcmsg = FocusChangeMessage(msg);
               this.hierarchy = new Array();
               for(this.currentDo = fcmsg.target; this.currentDo != null; )
               {
                  if(this.currentDo is UIComponent)
                  {
                     this.hierarchy.unshift(this.currentDo);
                  }
                  this.currentDo = this.currentDo.parent;
               }
               uiRootCtr = this.hierarchy[0] as UiRootContainer;
               input = this.hierarchy[this.hierarchy.length - 1] as Input;
               if(this.hierarchy.length > 0 && uiRootCtr && input && !uiRootCtr.uiData.module.trusted)
               {
                  if(!this._warning)
                  {
                     this._warning = new InputWarning();
                  }
                  Berilia.getInstance().docMain.addChild(this._warning);
                  this._warning.width = input.width;
                  inputPos = input.localToGlobal(new Point(input.x,input.y));
                  this._warning.x = inputPos.x;
                  this._warning.y = inputPos.y - this._warning.height - 4;
                  if(this._warning.y < 0)
                  {
                     this._warning.y = inputPos.y + input.height + 4;
                  }
                  if(this._warning.y + this._warning.height > StageShareManager.startHeight)
                  {
                     this._warning.y = (StageShareManager.startHeight - this._warning.height) / 2;
                  }
               }
               else if(this._warning && this._warning.parent)
               {
                  this._warning.parent.removeChild(this._warning);
               }
               if(this.hierarchy.length > 0)
               {
                  KernelEventsManager.getInstance().processCallback(BeriliaHookList.FocusChange,this.hierarchy[this.hierarchy.length - 1]);
               }
               else
               {
                  KernelEventsManager.getInstance().processCallback(BeriliaHookList.FocusChange,null);
               }
               return true;
            case msg is HumanInputMessage:
               this._isProcessingDirectInteraction = true;
               himsg = HumanInputMessage(msg);
               this.hierarchy = new Array();
               for(this.currentDo = himsg.target; this.currentDo != null; )
               {
                  if(this.currentDo is UIComponent)
                  {
                     this.hierarchy.push(this.currentDo);
                  }
                  this.currentDo = this.currentDo.parent;
               }
               if(msg is MouseClickMessage)
               {
                  KernelEventsManager.getInstance().processCallback(BeriliaHookList.MouseClick,MouseClickMessage(msg).target);
                  if(!this.hierarchy[this.hierarchy.length - 1])
                  {
                     KernelEventsManager.getInstance().processCallback(BeriliaHookList.FocusChange,MouseClickMessage(msg).target);
                  }
               }
               if(msg is MouseMiddleClickMessage)
               {
                  KernelEventsManager.getInstance().processCallback(BeriliaHookList.MouseMiddleClick,MouseMiddleClickMessage(msg).target);
               }
               if(msg is KeyboardKeyDownMessage)
               {
                  kkdmsg = KeyboardKeyDownMessage(msg);
                  KernelEventsManager.getInstance().processCallback(BeriliaHookList.KeyDown,kkdmsg.target,kkdmsg.keyboardEvent.keyCode);
               }
               if(msg is KeyboardKeyUpMessage)
               {
                  kkumsg = KeyboardKeyUpMessage(msg);
                  KernelEventsManager.getInstance().processCallback(BeriliaHookList.KeyUp,kkumsg.target,kkumsg.keyboardEvent.keyCode);
               }
               onlyGrid = false;
               dispatched = false;
               for each(uic in this.hierarchy)
               {
                  isGrid = UIComponent(uic) is Grid;
                  if(!onlyGrid || isGrid)
                  {
                     res = UIComponent(uic).process(himsg);
                     if(res)
                     {
                        if(isGrid && !himsg.canceled)
                        {
                           dispatched = true;
                           onlyGrid = true;
                        }
                        else
                        {
                           this.hierarchy = null;
                           this.currentDo = null;
                           this._isProcessingDirectInteraction = false;
                           ModuleLogger.log(himsg,uic);
                           return true;
                        }
                     }
                  }
                  if(!gridInstance && isGrid)
                  {
                     gridInstance = Grid(uic);
                  }
               }
               for(this.currentDo = himsg.target; this.currentDo != null; )
               {
                  if(this.currentDo is GraphicContainer)
                  {
                     UiSoundManager.getInstance().fromUiElement(this.currentDo as GraphicContainer,EventEnums.convertMsgToFct(getQualifiedClassName(msg)));
                  }
                  if(UIEventManager.getInstance().isRegisteredInstance(this.currentDo,msg))
                  {
                     dispatched = true;
                     this.processRegisteredUiEvent(msg,gridInstance);
                     break;
                  }
                  if(this.currentDo is GraphicContainer)
                  {
                     ModuleLogger.log(msg,this.currentDo);
                  }
                  this.currentDo = this.currentDo.parent;
               }
               if(msg is MouseClickMessage)
               {
                  KernelEventsManager.getInstance().processCallback(BeriliaHookList.PostMouseClick,MouseClickMessage(msg).target);
               }
               if(msg is MouseDoubleClickMessage && !dispatched)
               {
                  newMsg = GenericPool.get(MouseClickMessage,himsg.target as InteractiveObject,new MouseEvent(MouseEvent.CLICK));
                  Berilia.getInstance().handler.process(newMsg);
               }
               this.hierarchy = null;
               this.currentDo = null;
               this._isProcessingDirectInteraction = false;
               break;
            case msg is ComponentMessage:
               comsg = ComponentMessage(msg);
               this.hierarchy = new Array();
               for(this.currentDo = comsg.target; this.currentDo != null; )
               {
                  if(this.currentDo is UIComponent)
                  {
                     this.hierarchy.unshift(this.currentDo);
                  }
                  this.currentDo = this.currentDo.parent;
               }
               if(this.hierarchy.length == 0)
               {
                  this._isProcessingDirectInteraction = false;
                  return false;
               }
               for each(uic3 in this.hierarchy)
               {
                  UIComponent(uic3).process(comsg);
               }
               comsg.bubbling = true;
               this.hierarchy.reverse();
               this.hierarchy.pop();
               for each(uic4 in this.hierarchy)
               {
                  UIComponent(uic4).process(comsg);
               }
               this.hierarchy = null;
               if(!comsg.canceled)
               {
                  for each(act2 in comsg.actions)
                  {
                     Berilia.getInstance().handler.process(act2);
                  }
                  targetFct = EventEnums.convertMsgToFct(getQualifiedClassName(msg));
                  UiSoundManager.getInstance().fromUiElement(comsg.target as GraphicContainer,targetFct);
                  this.currentDo = comsg.target;
                  while(true)
                  {
                     if(this.currentDo == null)
                     {
                        break loop9;
                     }
                     if(UIEventManager.getInstance().instances[this.currentDo] && UIEventManager.getInstance().instances[this.currentDo].events[getQualifiedClassName(msg)])
                     {
                        ie2 = InstanceEvent(UIEventManager.getInstance().instances[this.currentDo]);
                        switch(true)
                        {
                           case msg is MouseMiddleClickMessage:
                           case msg is ChangeMessage:
                              args = [ie2.instance];
                              break;
                           case msg is BrowserSessionTimeout:
                              args = [ie2.instance];
                              break;
                           case msg is BrowserDomChange:
                           case msg is BrowserDomReady:
                              args = [ie2.instance];
                              break;
                           case msg is ColorChangeMessage:
                              args = [ie2.instance];
                              break;
                           case msg is EntityReadyMessage:
                              args = [ie2.instance];
                              break;
                           case msg is SelectItemMessage:
                              if(SelectItemMessage(msg).selectMethod != SelectMethodEnum.MANUAL && SelectItemMessage(msg).selectMethod != SelectMethodEnum.AUTO)
                              {
                                 this._isProcessingDirectInteraction = true;
                              }
                              args = [ie2.instance,SelectItemMessage(msg).selectMethod,SelectItemMessage(msg).isNewSelection];
                              break;
                           case msg is SelectEmptyItemMessage:
                              if(SelectEmptyItemMessage(msg).selectMethod != SelectMethodEnum.MANUAL && SelectEmptyItemMessage(msg).selectMethod != SelectMethodEnum.AUTO)
                              {
                                 this._isProcessingDirectInteraction = true;
                              }
                              args = [ie2.instance,SelectEmptyItemMessage(msg).selectMethod];
                              break;
                           case msg is ItemRollOverMessage:
                              args = [ie2.instance,ItemRollOverMessage(msg).item];
                              break;
                           case msg is ItemRollOutMessage:
                              args = [ie2.instance,ItemRollOutMessage(msg).item];
                              break;
                           case msg is ItemRightClickMessage:
                              this._isProcessingDirectInteraction = true;
                              args = [ie2.instance,ItemRightClickMessage(msg).item];
                              break;
                           case msg is TextureReadyMessage:
                              args = [ie2.instance];
                              break;
                           case msg is TextureLoadFailMessage:
                              args = [ie2.instance];
                              break;
                           case msg is DropMessage:
                              this._isProcessingDirectInteraction = true;
                              args = [DropMessage(msg).target,DropMessage(msg).source];
                              break;
                           case msg is CreateTabMessage:
                              args = [ie2.instance];
                              break;
                           case msg is DeleteTabMessage:
                              args = [ie2.instance,DeleteTabMessage(msg).deletedIndex];
                              break;
                           case msg is RenameTabMessage:
                              args = [ie2.instance,RenameTabMessage(msg).index,RenameTabMessage(msg).name];
                              break;
                           case msg is MapElementRollOverMessage:
                              args = [ie2.instance,MapElementRollOverMessage(msg).targetedElement];
                              break;
                           case msg is MapElementRollOutMessage:
                              args = [ie2.instance,MapElementRollOutMessage(msg).targetedElement];
                              break;
                           case msg is MapElementRightClickMessage:
                              args = [ie2.instance,MapElementRightClickMessage(msg).targetedElement];
                              break;
                           case msg is MapMoveMessage:
                              args = [ie2.instance];
                              break;
                           case msg is MapRollOverMessage:
                              args = [ie2.instance,MapRollOverMessage(msg).x,MapRollOverMessage(msg).y];
                              break;
                           case msg is MapRollOutMessage:
                              args = [ie2.instance];
                              break;
                           case msg is VideoConnectFailedMessage:
                              args = [ie2.instance];
                              break;
                           case msg is VideoConnectSuccessMessage:
                              args = [ie2.instance];
                              break;
                           case msg is VideoBufferChangeMessage:
                              args = [ie2.instance,VideoBufferChangeMessage(msg).state];
                              break;
                           case msg is ComponentReadyMessage:
                              args = [ie2.instance];
                              break;
                           case msg is TextClickMessage:
                              this._isProcessingDirectInteraction = true;
                              args = [ie2.instance,(msg as TextClickMessage).textEvent];
                        }
                        if(args)
                        {
                           ModuleLogger.log(msg,ie2.instance);
                           gcui = GraphicContainer(ie2.instance).getUi();
                           if(gcui)
                           {
                              ErrorManager.tryFunction(gcui.call,[ie2.callbackObject[targetFct],args,SecureCenter.ACCESS_KEY],"Erreur lors du traitement de " + msg);
                           }
                           this._isProcessingDirectInteraction = false;
                           return true;
                        }
                        break loop9;
                     }
                     this.currentDo = this.currentDo.parent;
                  }
                  break;
               }
               break;
         }
         this._isProcessingDirectInteraction = false;
         return false;
      }
      
      public function pushed() : Boolean
      {
         StageShareManager.stage.addEventListener(Event.RESIZE,this.onStageResize);
         StageShareManager.stage.nativeWindow.addEventListener(Event.DEACTIVATE,this.onWindowDeactivate);
         StageShareManager.stage.nativeWindow.addEventListener(Event.RESIZE,this.onNativeWindowResize);
         return true;
      }
      
      public function pulled() : Boolean
      {
         StageShareManager.stage.removeEventListener(Event.RESIZE,this.onStageResize);
         StageShareManager.stage.nativeWindow.removeEventListener(Event.DEACTIVATE,this.onWindowDeactivate);
         StageShareManager.stage.nativeWindow.removeEventListener(Event.RESIZE,this.onNativeWindowResize);
         if(this._warning && this._warning.parent)
         {
            this._warning.parent.removeChild(this._warning);
         }
         this._warning = null;
         return true;
      }
      
      private function processRegisteredUiEvent(msg:Message, gridInstance:Grid) : void
      {
         var args:* = null;
         var fct:* = null;
         var ie:InstanceEvent = InstanceEvent(UIEventManager.getInstance().instances[this.currentDo]);
         var fctName:String = EventEnums.convertMsgToFct(getQualifiedClassName(msg));
         ModuleLogger.log(msg,ie.instance);
         if(gridInstance)
         {
            if(msg is MouseWheelMessage)
            {
               args = [ie.instance,MouseWheelMessage(msg).mouseEvent.delta];
            }
            else
            {
               args = [ie.instance];
            }
            fct = gridInstance.renderer.eventModificator(msg,fctName,args,ie.instance as UIComponent);
            ErrorManager.tryFunction(CallWithParameters.call,[ie.callbackObject[fctName],args],"Erreur lors du traitement de " + msg);
         }
         else if(msg is MouseWheelMessage)
         {
            ErrorManager.tryFunction(ie.callbackObject[fctName],[ie.instance,MouseWheelMessage(msg).mouseEvent.delta]);
         }
         else
         {
            ErrorManager.tryFunction(ie.callbackObject[fctName],[ie.instance]);
         }
      }
      
      private function onStageResize(e:Event = null) : void
      {
         if(this._lastW == StageShareManager.stage.stageWidth && this._lastH == StageShareManager.stage.stageHeight)
         {
            return;
         }
         if(getTimer() - this._lastTs > 100)
         {
            this._lastTs = getTimer();
            this._lastW = StageShareManager.stage.stageWidth;
            this._lastH = StageShareManager.stage.stageHeight;
            KernelEventsManager.getInstance().processCallback(BeriliaHookList.WindowResize,this._lastW,this._lastH,StageShareManager.windowScale);
         }
         setTimeout(this.onStageResize,101);
      }
      
      private function onNativeWindowResize(e:Event = null) : void
      {
         if(this._lastWW == StageShareManager.stage.nativeWindow.width && this._lastWH == StageShareManager.stage.nativeWindow.height)
         {
            return;
         }
         if(getTimer() - this._lastWTs > 100)
         {
            this._lastWTs = getTimer();
            this._lastWW = StageShareManager.stage.stageWidth;
            this._lastWH = StageShareManager.stage.stageHeight;
            KernelEventsManager.getInstance().processCallback(BeriliaHookList.WindowResize,this._lastWW,this._lastWH,StageShareManager.windowScale);
         }
         setTimeout(this.onStageResize,101);
      }
      
      private function onWindowDeactivate(pEvent:Event) : void
      {
         if(Berilia.getInstance().docMain && Berilia.getInstance().docMain.stage)
         {
            Berilia.getInstance().docMain.stage.focus = null;
            FocusHandler.getInstance().setFocus(null);
         }
      }
   }
}

import com.ankamagames.jerakine.data.I18n;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

class InputWarning extends TextField
{
    
   
   function InputWarning()
   {
      super();
      background = true;
      backgroundColor = 7348259;
      autoSize = TextFieldAutoSize.LEFT;
      wordWrap = true;
      defaultTextFormat = new TextFormat("Verdana",12,16777215,true);
      text = I18n.getUiText("ui.module.input.warning");
   }
}
