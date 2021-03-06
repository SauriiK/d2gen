package com.ankamagames.atouin.managers
{
   import com.ankamagames.atouin.types.AnimatedElementInfo;
   import com.ankamagames.jerakine.sequencer.CallbackStep;
   import com.ankamagames.jerakine.sequencer.SerialSequencer;
   import com.ankamagames.jerakine.types.Callback;
   import com.ankamagames.jerakine.utils.display.StageShareManager;
   import com.ankamagames.tiphon.display.TiphonSprite;
   import com.ankamagames.tiphon.sequence.PlayAnimationStep;
   import com.ankamagames.tiphon.sequence.SetAnimationStep;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public final class AnimatedElementManager
   {
      
      private static var _elements:Vector.<AnimatedElementInfo>;
      
      private static const SEQUENCE_TYPE_NAME:String = "AnimatedElementManager_sequence";
      
      private static const MAX_ANIMATION_LENGTH:int = 20000;
       
      
      private var _sequenceRef:Dictionary;
      
      public function AnimatedElementManager()
      {
         this._sequenceRef = new Dictionary(true);
         super();
      }
      
      public static function reset() : void
      {
         var num:int = 0;
         var i:int = 0;
         var info:* = null;
         if(_elements)
         {
            num = _elements.length;
            i = -1;
            while(++i < num)
            {
               info = _elements[i];
               info.tiphonSprite.destroy();
            }
         }
         _elements = new Vector.<AnimatedElementInfo>();
         StageShareManager.stage.removeEventListener(Event.ENTER_FRAME,loop);
      }
      
      public static function addAnimatedElement(tiphonSprite:TiphonSprite, min:int, max:int) : void
      {
         if(_elements.length == 0)
         {
            StageShareManager.stage.addEventListener(Event.ENTER_FRAME,loop);
         }
         _elements.push(new AnimatedElementInfo(tiphonSprite,min,max));
      }
      
      public static function removeAnimatedElement(tiphonSprite:TiphonSprite) : void
      {
         for(var index:int = 0,var elem:* = null; index < _elements.length; )
         {
            elem = _elements[index];
            if(elem.tiphonSprite == tiphonSprite)
            {
               _elements.splice(index,1);
               if(_elements.length == 0)
               {
                  StageShareManager.stage.removeEventListener(Event.ENTER_FRAME,loop);
                  SerialSequencer.clearByType(SEQUENCE_TYPE_NAME);
               }
               return;
            }
            index++;
         }
      }
      
      public static function loop(e:Event) : void
      {
         var elementInfo:* = null;
         var seq:* = null;
         var playAnimStep:* = null;
         var time:int = getTimer();
         var i:int = -1;
         var num:int = _elements.length;
         while(++i < num)
         {
            elementInfo = _elements[i];
            if(time - elementInfo.nextAnimation > 0)
            {
               elementInfo.setNextAnimation();
               seq = new SerialSequencer(SEQUENCE_TYPE_NAME);
               playAnimStep = new PlayAnimationStep(elementInfo.tiphonSprite,"AnimStart",false);
               playAnimStep.timeout = MAX_ANIMATION_LENGTH;
               seq.addStep(playAnimStep);
               seq.addStep(new SetAnimationStep(elementInfo.tiphonSprite,"AnimStatique"));
               seq.addStep(new CallbackStep(new Callback(onSequenceEnd,seq,elementInfo.tiphonSprite)));
               seq.start();
            }
         }
      }
      
      private static function onSequenceEnd(sequence:SerialSequencer, ts:TiphonSprite) : void
      {
         sequence.clear();
         if(ts.getAnimation() == "AnimStart")
         {
            ts.stopAnimation();
         }
      }
   }
}
