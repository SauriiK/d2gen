package com.ankamagames.dofus.uiApi
{
   import com.ankamagames.berilia.interfaces.IApi;
   import com.ankamagames.berilia.types.data.UiModule;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.logic.game.common.frames.AveragePricesFrame;
   import com.ankamagames.jerakine.data.I18n;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.utils.misc.StringUtils;
   import flash.utils.getQualifiedClassName;
   
   [InstanciedApi]
   public class AveragePricesApi implements IApi
   {
       
      
      protected var _log:Logger;
      
      private var _module:UiModule;
      
      public function AveragePricesApi()
      {
         this._log = Log.getLogger(getQualifiedClassName(AveragePricesApi));
         super();
      }
      
      [ApiData(name="module")]
      public function set module(value:UiModule) : void
      {
         this._module = value;
      }
      
      [Trusted]
      public function destroy() : void
      {
         this._module = null;
      }
      
      [Trusted]
      public function getItemAveragePrice(pItemId:uint) : Number
      {
         var avgPrice:* = 0;
         if(this.dataAvailable())
         {
            avgPrice = Number(AveragePricesFrame.getInstance().pricesData.items["item" + pItemId]);
            if(!avgPrice || isNaN(avgPrice))
            {
               avgPrice = 0;
            }
         }
         return avgPrice;
      }
      
      [Trusted]
      public function getItemAveragePriceString(pItem:*, pAddLineBreakBefore:Boolean = false, htmlTagStart:String = "", htmlTagEnd:String = "") : String
      {
         var averagePrice:Number = NaN;
         var priceAvailable:* = false;
         var str:String = "";
         if(pItem.exchangeable)
         {
            averagePrice = this.getItemAveragePrice(pItem.objectGID);
            priceAvailable = averagePrice > 0;
            str = str + ((!!pAddLineBreakBefore?"\n":"") + I18n.getUiText("ui.item.averageprice") + I18n.getUiText("ui.common.colon") + htmlTagStart + (!!priceAvailable?StringUtils.kamasToString(averagePrice):I18n.getUiText("ui.item.averageprice.unavailable")) + htmlTagEnd);
            if(priceAvailable && pItem.quantity > 1)
            {
               str = str + ("\n" + I18n.getUiText("ui.item.averageprice.stack") + I18n.getUiText("ui.common.colon") + htmlTagStart + StringUtils.kamasToString(averagePrice * pItem.quantity) + htmlTagEnd);
            }
         }
         return str;
      }
      
      [Trusted]
      public function dataAvailable() : Boolean
      {
         var avgPricesFrame:AveragePricesFrame = Kernel.getWorker().getFrame(AveragePricesFrame) as AveragePricesFrame;
         return avgPricesFrame.dataAvailable;
      }
   }
}
