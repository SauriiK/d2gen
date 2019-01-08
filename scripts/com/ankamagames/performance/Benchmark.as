package com.ankamagames.performance
{
   import com.ankamagames.jerakine.managers.StoreDataManager;
   import com.ankamagames.jerakine.types.DataStoreType;
   import com.ankamagames.jerakine.types.enums.DataStoreEnum;
   import com.ankamagames.performance.tests.TestBandwidth;
   import com.ankamagames.performance.tests.TestDisplayPerformance;
   import com.ankamagames.performance.tests.TestReadDisk;
   import com.ankamagames.performance.tests.TestWriteDisk;
   import flash.display.Stage;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class Benchmark
   {
      
      public static const BENCHMARK_FORMAT_VERSION:uint = 1;
      
      public static const TESTS_DEFAULT:Vector.<Class> = new <Class>[TestBandwidth,TestWriteDisk,TestReadDisk,TestDisplayPerformance];
      
      public static const TESTS_NODISK:Vector.<Class> = new <Class>[TestBandwidth,TestDisplayPerformance];
      
      public static const TESTS_AIR:Vector.<Class> = new <Class>[TestWriteDisk,TestReadDisk,TestDisplayPerformance];
      
      public static var isDone:Boolean = false;
      
      private static var _ds:DataStoreType = new DataStoreType("Dofus_Benchmark",true,DataStoreEnum.LOCATION_LOCAL,DataStoreEnum.BIND_COMPUTER);
      
      private static var _totalTestToDo:uint;
      
      private static var _onCompleteCallback:Function;
      
      private static var _lastTests:Vector.<IBenchmarkTest>;
      
      private static var _timer:Timer;
       
      
      public function Benchmark()
      {
         super();
      }
      
      public static function get hasCachedResults() : Boolean
      {
         var results:* = StoreDataManager.getInstance().getData(_ds,"results");
         var formatVersion:uint = StoreDataManager.getInstance().getData(_ds,"formatVersion");
         if(formatVersion != BENCHMARK_FORMAT_VERSION)
         {
            results = null;
            StoreDataManager.getInstance().setData(_ds,"results",null);
            StoreDataManager.getInstance().setData(_ds,"formatVersion",BENCHMARK_FORMAT_VERSION);
         }
         return results != null;
      }
      
      public static function run(stage:Stage, onCompleteCallback:Function, tests:Vector.<Class> = null) : void
      {
         var test:* = null;
         var testClass:* = null;
         TestDisplayPerformance.stage = stage;
         if(!tests)
         {
            tests = TESTS_DEFAULT;
         }
         _totalTestToDo = tests.length;
         _onCompleteCallback = onCompleteCallback;
         isDone = false;
         _timer = new Timer(5000,1);
         _timer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimedOut);
         _timer.start();
         _lastTests = new Vector.<IBenchmarkTest>();
         for each(testClass in tests)
         {
            test = new testClass();
            _lastTests.push(test);
            test.run();
         }
      }
      
      protected static function onTimedOut(event:TimerEvent) : void
      {
         var test:* = null;
         for each(test in _lastTests)
         {
            test.cancel();
         }
         endBenchmark();
      }
      
      private static function cleanTimer() : void
      {
         if(_timer)
         {
            _timer.stop();
            _timer.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimedOut);
            _timer = null;
         }
      }
      
      public static function onTestCompleted(test:IBenchmarkTest) : void
      {
         _totalTestToDo--;
         if(_totalTestToDo == 0)
         {
            endBenchmark();
         }
      }
      
      private static function endBenchmark() : void
      {
         cleanTimer();
         Benchmark.isDone = true;
         if(_onCompleteCallback != null)
         {
            _onCompleteCallback();
            _onCompleteCallback = null;
         }
      }
      
      public static function getResults(writeResultsOnDisk:Boolean = false, fromCacheIfExists:Boolean = true) : String
      {
         var test:* = null;
         var res:String = "";
         if(fromCacheIfExists)
         {
            res = StoreDataManager.getInstance().getData(_ds,"results");
            if(res && res.length > 0)
            {
               return res;
            }
            res = "";
         }
         for each(test in _lastTests)
         {
            res = res + (test.getResults() + ";");
         }
         res = res.slice(0,-1);
         if(writeResultsOnDisk)
         {
            StoreDataManager.getInstance().setData(_ds,"results",res);
            StoreDataManager.getInstance().setData(_ds,"formatVersion",BENCHMARK_FORMAT_VERSION);
         }
         return res;
      }
   }
}
