package com.ankamagames.tubul.types
{
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.utils.display.StageShareManager;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.SampleDataEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   
   public class SoundMerger extends EventDispatcher
   {
      
      private static const DATA_SAMPLES_BUFFER_SIZE:uint = 4096;
      
      private static const SILENCE_SAMPLES_BUFFER_SIZE:uint = 2048;
      
      public static const MINIMAL_LENGTH_TO_MERGE:uint = 3500;
      
      public static const MAXIMAL_LENGTH_TO_MERGE:uint = 10000;
      
      private static const _log:Logger = Log.getLogger(getQualifiedClassName(SoundMerger));
       
      
      private var _output:Sound;
      
      private var _outputChannel:SoundChannel;
      
      private var _sounds:Vector.<SoundWrapper>;
      
      private var _soundsCount:uint;
      
      private var _directlyPlayed:Dictionary;
      
      private var _directChannels:Dictionary;
      
      private var _outputBytes:ByteArray;
      
      private var _cuttingBytes:ByteArray;
      
      public function SoundMerger()
      {
         super();
         this.init();
      }
      
      public function getSoundChannel(sw:SoundWrapper) : SoundChannel
      {
         return this._directlyPlayed[sw];
      }
      
      public function addSound(sw:SoundWrapper) : void
      {
         this.directPlay(sw,sw.loops);
      }
      
      public function removeSound(sw:SoundWrapper) : void
      {
         var soundPos:int = this._sounds.indexOf(sw);
         if(soundPos != -1)
         {
            this._sounds.splice(soundPos,1);
            sw.dispatchEvent(new Event(Event.SOUND_COMPLETE));
            if(!--this._soundsCount)
            {
               this.setSilence(true);
            }
         }
         else if(this._directlyPlayed[sw])
         {
            this.directStop(sw);
         }
      }
      
      private function init() : void
      {
         this._sounds = new Vector.<SoundWrapper>();
         this._directlyPlayed = new Dictionary();
         this._directChannels = new Dictionary();
         this._cuttingBytes = new ByteArray();
         this._output = new Sound();
         this._output.addEventListener(SampleDataEvent.SAMPLE_DATA,this.sampleSilence);
         this._outputChannel = this._output.play();
         StageShareManager.stage.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function setSilence(activated:Boolean) : void
      {
         if(activated)
         {
            this._output.removeEventListener(SampleDataEvent.SAMPLE_DATA,this.sampleData);
            this._output.addEventListener(SampleDataEvent.SAMPLE_DATA,this.sampleSilence);
         }
         else
         {
            this._output.addEventListener(SampleDataEvent.SAMPLE_DATA,this.sampleData);
            this._output.removeEventListener(SampleDataEvent.SAMPLE_DATA,this.sampleSilence);
         }
      }
      
      private function directPlay(sw:SoundWrapper, loops:int) : void
      {
         var directChannel:* = null;
         if(!StageShareManager.stage.hasEventListener(Event.ENTER_FRAME))
         {
            StageShareManager.stage.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
         directChannel = sw.sound.play(0,1,sw.getSoundTransform());
         if(directChannel == null)
         {
            _log.warn("cannot play sound in the directChannel, it is probably full !");
            return;
         }
         if(this._directlyPlayed[sw] != null)
         {
            this._directChannels[this._directlyPlayed[sw]] = null;
            delete this._directChannels[this._directlyPlayed[sw]];
         }
         this._directlyPlayed[sw] = directChannel;
         this._directChannels[directChannel] = sw;
         if(!directChannel.hasEventListener(Event.SOUND_COMPLETE))
         {
            directChannel.addEventListener(Event.SOUND_COMPLETE,this.directSoundComplete);
         }
      }
      
      private function directStop(sw:SoundWrapper, eventDispatched:Boolean = false) : void
      {
         var directChannel:SoundChannel = this._directlyPlayed[sw];
         directChannel.removeEventListener(Event.SOUND_COMPLETE,this.directSoundComplete);
         directChannel.stop();
         sw.currentLoop = 0;
         if(!eventDispatched)
         {
            sw.dispatchEvent(new Event(Event.SOUND_COMPLETE));
         }
         delete this._directlyPlayed[sw];
         delete this._directChannels[directChannel];
         if(StageShareManager.stage.hasEventListener(Event.ENTER_FRAME) && this._directChannels.length == 0)
         {
            StageShareManager.stage.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
      }
      
      private function sampleData(sde:SampleDataEvent) : void
      {
         var previousPosition:* = 0;
         var samplesRemaining:Number = NaN;
         var samplesExtracted:Number = NaN;
         var cutValueR:Number = NaN;
         var cutValueL:Number = NaN;
         var cutSamples:* = 0;
         var cuttingPosition:* = 0;
         var i:* = 0;
         var j:int = 0;
         var baHolder:* = null;
         var sw:* = null;
         var extractFinished:* = false;
         var l:* = NaN;
         var r:* = NaN;
         var sl:Number = NaN;
         var sr:Number = NaN;
         var firstPass:Boolean = false;
         var startSampleData:uint = getTimer();
         var out:ByteArray = sde.data;
         for(j = 0; j < this._soundsCount; j++)
         {
            sw = this._sounds[j] as SoundWrapper;
            if(!sw._extractFinished)
            {
               samplesRemaining = DATA_SAMPLES_BUFFER_SIZE;
               previousPosition = uint(sw.soundData.position);
               firstPass = true;
               do
               {
                  if(previousPosition == 0 && firstPass)
                  {
                     samplesExtracted = sw.sound.extract(sw.soundData,samplesRemaining,0);
                  }
                  else
                  {
                     samplesExtracted = sw.sound.extract(sw.soundData,samplesRemaining);
                  }
                  firstPass = false;
                  extractFinished = samplesExtracted != samplesRemaining;
                  if(!sw.hadBeenCut && (sw.loops == 0 || sw.loops > 1))
                  {
                     sw.currentLoop++;
                     sw.soundData.position = cuttingPosition;
                     for(i = 0; i < samplesExtracted; i++)
                     {
                        cutValueR = sw.soundData.readFloat();
                        cutValueL = sw.soundData.readFloat();
                        if(cutValueR > 0.001 || cutValueR < -0.001 || cutValueL > 0.001 || cutValueL < -0.001)
                        {
                           sw.hadBeenCut = true;
                           break;
                        }
                     }
                     cutSamples = uint(i + 1);
                     for(i = uint(i + 1); i < samplesExtracted; i++)
                     {
                        this._cuttingBytes.writeFloat(sw.soundData.readFloat());
                        this._cuttingBytes.writeFloat(sw.soundData.readFloat());
                     }
                     if(this._cuttingBytes.length > 0)
                     {
                        samplesRemaining = samplesRemaining + cutSamples;
                        baHolder = sw.soundData;
                        sw.soundData = this._cuttingBytes;
                        this._cuttingBytes = baHolder;
                        this._cuttingBytes.clear();
                     }
                     else
                     {
                        cuttingPosition = uint(cuttingPosition + DATA_SAMPLES_BUFFER_SIZE * 8);
                        samplesRemaining = samplesRemaining + DATA_SAMPLES_BUFFER_SIZE;
                     }
                  }
                  if(extractFinished)
                  {
                     sw.extractFinished();
                     break;
                  }
                  samplesRemaining = samplesRemaining - samplesExtracted;
               }
               while(samplesRemaining > 0);
               
               sw.soundData.position = previousPosition;
            }
         }
         for(i = 0; i < DATA_SAMPLES_BUFFER_SIZE; i++)
         {
            l = Number(r = 0);
            for(j = 0; j < this._soundsCount; j++)
            {
               if(i == 0)
               {
                  sw.checkSoundPosition();
               }
               sw = this._sounds[j] as SoundWrapper;
               if(sw.soundData.bytesAvailable < 8)
               {
                  if(sw.loops == 0 || sw.loops > 1 && sw.currentLoop + 1 < sw.loops)
                  {
                     sw.soundData.position = 0;
                     sw.currentLoop++;
                  }
                  else
                  {
                     this.removeSound(sw);
                     break;
                  }
               }
               else
               {
                  sl = sw.soundData.readFloat() * sw._volume * (1 - sw._pan);
                  sr = sw.soundData.readFloat() * sw._volume * (1 + sw._pan);
                  l = Number(l + (sl * sw._leftToLeft + sr * sw._rightToLeft));
                  r = Number(r + (sl * sw._leftToRight + sr * sw._rightToRight));
               }
            }
            if(l > 1)
            {
               l = 1;
            }
            if(l < -1)
            {
               l = -1;
            }
            if(r > 1)
            {
               r = 1;
            }
            if(r < -1)
            {
               r = -1;
            }
            out.writeFloat(l);
            out.writeFloat(r);
         }
      }
      
      private function sampleSilence(sde:SampleDataEvent) : void
      {
         for(var i:int = 0; i < SILENCE_SAMPLES_BUFFER_SIZE; i++)
         {
            sde.data.writeFloat(0);
            sde.data.writeFloat(0);
         }
      }
      
      private function directSoundComplete(e:Event) : void
      {
         var sw:SoundWrapper = this._directChannels[e.target];
         sw.currentLoop++;
         if(sw.currentLoop < sw.loops || sw.loops == 0)
         {
            this.directPlay(sw,sw.loops);
         }
         else
         {
            this.directStop(sw,true);
            sw.dispatchEvent(e);
         }
      }
      
      private function onEnterFrame(pEvent:Event) : void
      {
         var sw:* = null;
         for each(sw in this._directChannels)
         {
            sw.checkSoundPosition();
         }
      }
   }
}
