package com.somerandomdude.colortoolkit.spaces
{
   import com.somerandomdude.colortoolkit.CoreColor;
   
   public class Lab extends CoreColor implements IColorSpace
   {
       
      
      private var _lightness:Number;
      
      private var _a:Number;
      
      private var _b:Number;
      
      public function Lab(lightness:Number = 0, a:Number = 0, b:Number = 0)
      {
         super();
         this._lightness = lightness;
         this._a = a;
         this._b = b;
         this._color = this.generateColorFromLab(this._lightness,this._a,this._b);
      }
      
      public function get color() : int
      {
         return this._color;
      }
      
      public function set color(value:int) : void
      {
         this._color = value;
         var lab:Lab = this.generateLabFromHex(value);
         this._lightness = lab.lightness;
         this._a = lab.a;
         this._b = lab.b;
      }
      
      public function get lightness() : Number
      {
         return this._lightness;
      }
      
      public function set lightness(value:Number) : void
      {
         this._lightness = value;
         this._color = this.generateColorFromLab(this._lightness,this._a,this._b);
      }
      
      public function get a() : Number
      {
         return this._a;
      }
      
      public function set a(value:Number) : void
      {
         this._a = value;
         this._color = this.generateColorFromLab(this._lightness,this._a,this._b);
      }
      
      public function get b() : Number
      {
         return this._b;
      }
      
      public function set b(value:Number) : void
      {
         this._b = value;
         this._color = this.generateColorFromLab(this._lightness,this._a,this._b);
      }
      
      public function clone() : IColorSpace
      {
         return new Lab(this._lightness,this._a,this._b);
      }
      
      private function generateColorFromLab(lightness:Number, a:Number, b:Number) : int
      {
         var y:Number = (lightness + 16) / 116;
         var x:Number = a / 500 + y;
         var z:Number = y - b / 200;
         if(Math.pow(y,3) > 0.008856)
         {
            y = Math.pow(y,3);
         }
         else
         {
            y = (y - 0.137931034482759) / 7.787;
         }
         if(Math.pow(x,3) > 0.008856)
         {
            x = Math.pow(x,3);
         }
         else
         {
            x = (x - 0.137931034482759) / 7.787;
         }
         if(Math.pow(z,3) > 0.008856)
         {
            z = Math.pow(z,3);
         }
         else
         {
            z = (z - 0.137931034482759) / 7.787;
         }
         var xyz:XYZ = new XYZ(95.047 * x,100 * y,108.883 * z);
         return xyz.color;
      }
      
      private function generateLabFromHex(color:int) : Lab
      {
         var xyz:XYZ = new XYZ();
         xyz.color = color;
         var x:Number = xyz.x / 95.047;
         var y:Number = xyz.y / 100;
         var z:Number = xyz.z / 108.883;
         if(x > 0.008856)
         {
            x = Math.pow(x,0.333333333333333);
         }
         else
         {
            x = 7.787 * x + 0.137931034482759;
         }
         if(y > 0.008856)
         {
            y = Math.pow(y,0.333333333333333);
         }
         else
         {
            y = 7.787 * y + 0.137931034482759;
         }
         if(z > 0.008856)
         {
            z = Math.pow(z,0.333333333333333);
         }
         else
         {
            z = 7.787 * z + 0.137931034482759;
         }
         return new Lab(116 * y - 16,500 * (x - y),200 * (y - z));
      }
   }
}
