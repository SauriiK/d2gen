package com.ankamagames.performance
{
   import com.ankamagames.performance.tests.TestDisplayPerformance;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   
   public class DisplayObjectDummy extends Sprite
   {
       
      
      private var _stage:Stage;
      
      public function DisplayObjectDummy(color:uint, pStage:Stage)
      {
         super();
         graphics.beginFill(color);
         graphics.drawRect(0,0,24,24);
         graphics.endFill();
         this._stage = pStage;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
      }
      
      protected function onAddedToStage(event:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         addEventListener(Event.ENTER_FRAME,this.onFrame);
      }
      
      protected function onFrame(event:Event) : void
      {
         if(!this._stage)
         {
            return;
         }
         rotation = TestDisplayPerformance.random.nextDouble() * 360;
         x = x + TestDisplayPerformance.random.nextDoubleR(-1,1) * 20;
         y = y + TestDisplayPerformance.random.nextDoubleR(-1,1) * 20;
         scaleX = scaleY = TestDisplayPerformance.random.nextDoubleR(-2,2);
         if(x > this._stage.stageWidth || x < 0)
         {
            x = this._stage.stageWidth / 2;
         }
         if(y > this._stage.stageHeight || y < 0)
         {
            y = this._stage.stageHeight / 2;
         }
      }
      
      public function destroy() : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.ENTER_FRAME,this.onFrame);
         this._stage = null;
      }
   }
}
