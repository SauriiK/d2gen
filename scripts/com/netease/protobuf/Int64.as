package com.netease.protobuf
{
   public final class Int64 extends Binary64
   {
       
      
      public function Int64(low:uint = 0, high:int = 0)
      {
         super(low,high);
      }
      
      public static function fromNumber(n:Number) : Int64
      {
         return new Int64(n,Math.floor(n / 4294967296));
      }
      
      public static function parseInt64(str:String, radix:uint = 0) : Int64
      {
         var digit:* = 0;
         var negative:* = str.search(/^\-/) == 0;
         var i:uint = !!negative?1:uint(0);
         if(radix == 0)
         {
            if(str.search(/^\-?0x/) == 0)
            {
               radix = 16;
               i = i + 2;
            }
            else
            {
               radix = 10;
            }
         }
         if(radix < 2 || radix > 36)
         {
            throw new ArgumentError();
         }
         str = str.toLowerCase();
         for(var result:Int64 = new Int64(); i < str.length; )
         {
            digit = uint(str.charCodeAt(i));
            if(digit >= CHAR_CODE_0 && digit <= CHAR_CODE_9)
            {
               digit = uint(digit - CHAR_CODE_0);
            }
            else if(digit >= CHAR_CODE_A && digit <= CHAR_CODE_Z)
            {
               digit = uint(digit - CHAR_CODE_A);
               digit = uint(digit + 10);
            }
            else
            {
               throw new ArgumentError();
            }
            if(digit >= radix)
            {
               throw new ArgumentError();
            }
            result.mul(radix);
            result.add(digit);
            i++;
         }
         if(negative)
         {
            result.bitwiseNot();
            result.add(1);
         }
         return result;
      }
      
      public final function set high(value:int) : void
      {
         internalHigh = value;
      }
      
      public final function get high() : int
      {
         return internalHigh;
      }
      
      public final function toNumber() : Number
      {
         return this.high * 4294967296 + low;
      }
      
      public final function toString(radix:uint = 10) : String
      {
         var digit:* = 0;
         if(radix < 2 || radix > 36)
         {
            throw new ArgumentError();
         }
         switch(this.high)
         {
            case 0:
               return low.toString(radix);
            case -1:
               if((low & 2147483648) == 0)
               {
                  return (int(low | 2147483648) - 2147483648).toString(radix);
               }
               return int(low).toString(radix);
            default:
               if(low == 0 && this.high == 0)
               {
                  return "0";
               }
               var digitChars:* = [];
               var copyOfThis:UInt64 = new UInt64(low,this.high);
               if(this.high < 0)
               {
                  copyOfThis.bitwiseNot();
                  copyOfThis.add(1);
               }
               do
               {
                  digit = uint(copyOfThis.div(radix));
                  if(digit < 10)
                  {
                     digitChars.push(digit + CHAR_CODE_0);
                  }
                  else
                  {
                     digitChars.push(digit - 10 + CHAR_CODE_A);
                  }
               }
               while(copyOfThis.high != 0);
               
               if(this.high < 0)
               {
                  return "-" + copyOfThis.low.toString(radix) + String.fromCharCode.apply(String,digitChars.reverse());
               }
               return copyOfThis.low.toString(radix) + String.fromCharCode.apply(String,digitChars.reverse());
         }
      }
   }
}
