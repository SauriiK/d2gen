package com.ankamagames.dofus.misc.utils.errormanager
{
   import com.ankamagames.atouin.Atouin;
   import com.ankamagames.atouin.AtouinConstants;
   import com.ankamagames.atouin.managers.EntitiesManager;
   import com.ankamagames.atouin.utils.DataMapProvider;
   import com.ankamagames.berilia.managers.ThemeManager;
   import com.ankamagames.dofus.BuildInfos;
   import com.ankamagames.dofus.internalDatacenter.fight.FighterInformations;
   import com.ankamagames.dofus.internalDatacenter.world.WorldPointWrapper;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.kernel.updaterv2.UpdaterApi;
   import com.ankamagames.dofus.kernel.updaterv2.UpdaterConnexionHelper;
   import com.ankamagames.dofus.logic.common.managers.PlayerManager;
   import com.ankamagames.dofus.logic.connection.managers.AuthentificationManager;
   import com.ankamagames.dofus.logic.game.common.frames.AbstractEntitiesFrame;
   import com.ankamagames.dofus.logic.game.common.managers.PlayedCharacterManager;
   import com.ankamagames.dofus.logic.game.common.managers.SteamManager;
   import com.ankamagames.dofus.logic.game.fight.frames.FightContextFrame;
   import com.ankamagames.dofus.logic.game.fight.frames.FightEntitiesFrame;
   import com.ankamagames.dofus.logic.game.roleplay.frames.RoleplayEntitiesFrame;
   import com.ankamagames.dofus.misc.BuildTypeParser;
   import com.ankamagames.dofus.misc.EntityLookAdapter;
   import com.ankamagames.dofus.misc.interClient.InterClientManager;
   import com.ankamagames.dofus.misc.utils.DebugTarget;
   import com.ankamagames.dofus.network.ProtocolConstantsEnum;
   import com.ankamagames.dofus.network.enums.BuildTypeEnum;
   import com.ankamagames.dofus.network.types.game.context.GameContextActorInformations;
   import com.ankamagames.dofus.network.types.game.interactive.InteractiveElement;
   import com.ankamagames.jerakine.entities.interfaces.IEntity;
   import com.ankamagames.jerakine.enum.OperatingSystem;
   import com.ankamagames.jerakine.handlers.AbstractErrorHandler;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.LogEvent;
   import com.ankamagames.jerakine.logger.TextLogEvent;
   import com.ankamagames.jerakine.logger.targets.LimitedBufferTarget;
   import com.ankamagames.jerakine.managers.ErrorManager;
   import com.ankamagames.jerakine.managers.LangManager;
   import com.ankamagames.jerakine.messages.Frame;
   import com.ankamagames.jerakine.types.CustomSharedObject;
   import com.ankamagames.jerakine.types.events.ErrorReportedEvent;
   import com.ankamagames.jerakine.types.positions.MapPoint;
   import com.ankamagames.jerakine.utils.display.StageShareManager;
   import com.ankamagames.jerakine.utils.misc.DescribeTypeCache;
   import com.ankamagames.jerakine.utils.system.SystemManager;
   import com.ankamagames.jerakine.utils.system.SystemPopupUI;
   import flash.desktop.NativeApplication;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.geom.Matrix;
   import flash.system.Capabilities;
   import flash.system.System;
   import flash.ui.Keyboard;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   
   public class DofusErrorHandler extends AbstractErrorHandler
   {
      
      public static var maxStackTracelength:uint = 1000;
      
      private static const MANUAL_BUG_REPORT_TXT:String = "Manual bug report";
      
      private static var _lastError:uint;
      
      private static var _self:DofusErrorHandler;
       
      
      private var _localSaveReport:Boolean = false;
      
      private var _distantSaveReport:Boolean = false;
      
      private var _sendErrorToWebservice:Boolean = false;
      
      public function DofusErrorHandler(autoInit:Boolean = true)
      {
         super("Dofus","",autoInit);
         _self = this;
      }
      
      public static function get manualActivation() : Boolean
      {
         var manualActivation:CustomSharedObject = CustomSharedObject.getLocal("BugReport");
         return manualActivation.data && manualActivation.data.force;
      }
      
      public static function set manualActivation(v:Boolean) : void
      {
         var manualActivation:CustomSharedObject = CustomSharedObject.getLocal("BugReport");
         if(!manualActivation.data)
         {
            manualActivation.data = {};
         }
         manualActivation.data.force = v;
         manualActivation.flush();
      }
      
      public static function get debugFileExists() : Boolean
      {
         return File.applicationDirectory.resolvePath("debug").exists || File.applicationDirectory.resolvePath("debug.txt").exists;
      }
      
      public static function activateDebugMode() : void
      {
         _self.activeManually();
      }
      
      public static function captureMessage(message:String, tags:Object = null, level:int = 40) : void
      {
         _self.captureMessage(message,tags,level);
      }
      
      override protected function init() : void
      {
         super.init();
         this.activeManually();
         switch(BuildInfos.BUILD_TYPE)
         {
            case BuildTypeEnum.RELEASE:
               break;
            case BuildTypeEnum.BETA:
            case BuildTypeEnum.ALPHA:
               this._localSaveReport = true;
               this.activeWebService();
               break;
            case BuildTypeEnum.TESTING:
            case BuildTypeEnum.EXPERIMENTAL:
            case BuildTypeEnum.INTERNAL:
               this.activeSOS();
               this.activeShortcut();
               ErrorManager.showPopup = true;
               this.activeWebService();
               this._localSaveReport = true;
               this._distantSaveReport = true;
               break;
            default:
               this.activeSOS();
               this.activeShortcut();
               this._localSaveReport = true;
               this._distantSaveReport = true;
         }
         if(BuildInfos.BUILD_TYPE != BuildTypeEnum.DEBUG)
         {
            initSentry(BuildInfos.VERSION,BuildInfos.buildTypeName,BuildInfos.VERSION.buildType >= BuildTypeEnum.TESTING);
         }
      }
      
      public function activeManually() : void
      {
         if(debugFileExists || manualActivation)
         {
            this.activeShortcut();
            this.activeSOS();
            this.updateDebugFile();
            Log.exitIfNoConfigFile = false;
            this._localSaveReport = true;
         }
      }
      
      override protected function updateDebugFile() : void
      {
         if(debugFileExists || manualActivation || _sentryLevel != SENTRY_DISABLED)
         {
            createDebugFile();
         }
         else
         {
            removeDebugFile();
         }
      }
      
      private function onKeyUp(e:KeyboardEvent) : void
      {
         if(SystemManager.getSingleton().os == OperatingSystem.MAC_OS)
         {
            if(e.keyCode == Keyboard.F1)
            {
               this.onError(new ErrorReportedEvent(null,MANUAL_BUG_REPORT_TXT));
            }
         }
         else if(e.keyCode == Keyboard.F11)
         {
            this.onError(new ErrorReportedEvent(null,MANUAL_BUG_REPORT_TXT));
         }
      }
      
      public function activeSOS() : void
      {
         var fs:* = null;
         var sosFile:File = new File(File.applicationDirectory.resolvePath("log4as.xml").nativePath);
         if(!sosFile.exists)
         {
            fs = new FileStream();
            fs.open(sosFile,FileMode.WRITE);
            fs.writeUTFBytes(<logging>
					<targets>
						<target module="com.ankamagames.jerakine.logger.targets.SOSTarget"/>
					</targets>
				</logging>);
            fs.close();
         }
         Log.addTarget(new DebugTarget());
      }
      
      public function activeShortcut(e:Event = null) : void
      {
         Dofus.getInstance().stage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
      }
      
      public function activeWebService() : void
      {
         this._sendErrorToWebservice = true;
         if(WebServiceDataHandler.buffer == null)
         {
            WebServiceDataHandler.buffer = new LimitedBufferTarget(50);
            Log.addTarget(WebServiceDataHandler.buffer);
         }
      }
      
      override protected function onError(e:ErrorReportedEvent) : void
      {
         var error:Error = null;
         var report:ErrorReport = null;
         var stackTrace:String = null;
         var realStacktrace:String = null;
         var tmp:Array = null;
         var line:String = null;
         var exception:DataExceptionModel = null;
         var buttons:Array = null;
         var popup:SystemPopupUI = null;
         super.onError(e);
         var txt:String = e.text;
         error = e.error;
         if(error && error.getStackTrace())
         {
            if(txt.length)
            {
               txt = txt + "\n\n";
            }
            stackTrace = "";
            realStacktrace = error.getStackTrace();
            tmp = realStacktrace.split("\n");
            for each(line in tmp)
            {
               if(line.indexOf("ErrorManager") == -1 || line.indexOf("addError") == -1)
               {
                  stackTrace = stackTrace + ((!!stackTrace.length?"\n":"") + line);
               }
            }
            txt = txt + stackTrace.substr(0,maxStackTracelength);
            if(stackTrace.length > maxStackTracelength)
            {
               txt = txt + " ...";
            }
         }
         var reportInfo:Object = this.getReportInfo(error,e.text);
         report = new ErrorReport(reportInfo,_logBuffer);
         _lastError = getTimer();
         if(this._sendErrorToWebservice)
         {
            exception = WebServiceDataHandler.getInstance().createNewException(reportInfo,e.errorType);
            if(exception != null)
            {
               WebServiceDataHandler.getInstance().saveException(exception);
            }
         }
         if(e.showPopup)
         {
            buttons = [];
            popup = new SystemPopupUI("exception" + Math.random());
            popup.width = 1000;
            popup.centerContent = false;
            popup.title = "Information";
            popup.content = txt;
            buttons.push({"label":"Skip"});
            if(error)
            {
               buttons.push({
                  "label":"Copy to clipboard",
                  "callback":function():void
                  {
                     System.setClipboard(e.text + "\n\n" + error.getStackTrace());
                  }
               });
            }
            if(this._localSaveReport)
            {
               buttons.push({
                  "label":"Save report",
                  "callback":function():void
                  {
                     report.saveReport();
                  }
               });
            }
            if(this._distantSaveReport)
            {
               buttons.push({
                  "label":"Send report",
                  "callback":function():void
                  {
                     report.sendReport();
                  }
               });
            }
            popup.buttons = buttons;
            popup.show();
         }
      }
      
      override protected function getUserInfo() : Object
      {
         var o:Object = super.getUserInfo();
         if(PlayerManager.getInstance().accountId != 0)
         {
            o.id = PlayerManager.getInstance().accountId;
         }
         if(AuthentificationManager.getInstance().username)
         {
            o.username = AuthentificationManager.getInstance().username;
         }
         return o;
      }
      
      override protected function getTags() : Object
      {
         var o:Object = super.getTags();
         if(StageShareManager.stage && !StageShareManager.stage.nativeWindow.closed)
         {
            o.resolution = StageShareManager.stage.nativeWindow.width + "x" + StageShareManager.stage.nativeWindow.height;
         }
         o.multiAccount = !InterClientManager.getInstance().isAlone;
         if(PlayerManager.getInstance().server)
         {
            o.serverId = PlayerManager.getInstance().server.id;
            o.serverName = PlayerManager.getInstance().server.name;
         }
         if(PlayedCharacterManager.getInstance().infos)
         {
            o.characterName = PlayedCharacterManager.getInstance().infos.name;
            o.characterId = PlayedCharacterManager.getInstance().id;
            o.bddCharacterId = PlayedCharacterManager.getInstance().extractedServerCharacterIdFromInterserverCharacterId;
         }
         o.lang = LangManager.getInstance().lang;
         o.isUsingSteam = SteamManager.hasSteamApi() && SteamManager.getInstance().isSteamEmbed();
         o.isUsingUpdater = UpdaterConnexionHelper.hasUpdaterArgument();
         o.isUsingZaap = UpdaterConnexionHelper.hasZaapArguments();
         o.isUsingZaapLogin = UpdaterApi.canLoginWithZaap();
         o.isConnectedToZaapOrUpdater = UpdaterApi.isConnected();
         o.isSubscribed = PlayerManager.getInstance().subscriptionEndDate > 0;
         o.isAdmin = PlayerManager.getInstance().hasRights;
         if(ThemeManager.getInstance().currentTheme)
         {
            o.theme = ThemeManager.getInstance().currentTheme;
         }
         var currentMap:WorldPointWrapper = PlayedCharacterManager.getInstance().currentMap;
         if(currentMap)
         {
            o.mapId = currentMap.mapId;
            o.mapCoordinates = currentMap.x + "," + currentMap.y;
         }
         o.isFighting = PlayedCharacterManager.getInstance().isFighting;
         o.isSpectator = PlayedCharacterManager.getInstance().isSpectator;
         if(PlayedCharacterManager.getInstance().isFighting)
         {
            o.isPlayerTurn = this.getFightFrame().battleFrame.currentPlayerId == PlayedCharacterManager.getInstance().id;
         }
         return o;
      }
      
      override protected function getExtras() : Object
      {
         var flashKeyParts:* = null;
         var o:Object = super.getExtras();
         if(PlayerManager.getInstance().nickname)
         {
            o.nickname = PlayerManager.getInstance().nickname;
         }
         var flashKey:String = InterClientManager.getInstance().flashKey;
         if(flashKey)
         {
            flashKeyParts = flashKey.split("#");
            o.flashKey = new Object();
            if(flashKeyParts.length > 1)
            {
               o.flashKey.id = parseInt(flashKeyParts[1]);
            }
            o.flashKey.base = flashKeyParts[0];
         }
         if(PlayedCharacterManager.getInstance().infos)
         {
            o.look = EntityLookAdapter.fromNetwork(PlayedCharacterManager.getInstance().infos.entityLook).toString();
         }
         if(PlayedCharacterManager.getInstance().isFighting)
         {
            o.fightId = PlayedCharacterManager.getInstance().fightId;
         }
         return o;
      }
      
      public function getReportInfo(error:Error, txt:String) : Object
      {
         var date:Date = null;
         var o:Object = null;
         var userNameData:Array = null;
         var currentMap:WorldPointWrapper = null;
         var obstacles:Array = null;
         var entities:Array = null;
         var los:Array = null;
         var cellId:uint = 0;
         var mp:MapPoint = null;
         var fightContextFrame:FightContextFrame = null;
         var entityInfoProvider:AbstractEntitiesFrame = null;
         var htmlBuffer:String = null;
         var logs:Array = null;
         var log:LogEvent = null;
         var screenshot:BitmapData = null;
         var m:Matrix = null;
         var fightId:int = 0;
         var fighterBuffer:String = null;
         var fighters:Vector.<Number> = null;
         var fighterId:Number = NaN;
         var fighterInfos:FighterInformations = null;
         var level:int = 0;
         var levelText:String = null;
         var entitiesOnCell:Array = null;
         var entity:IEntity = null;
         var entityInfo:GameContextActorInformations = null;
         var entityInfoData:Array = null;
         var entityInfoDataStr:String = null;
         var key:String = null;
         var interactiveElements:Vector.<InteractiveElement> = null;
         var ie:InteractiveElement = null;
         var ieInfoData:Array = null;
         var iePos:MapPoint = null;
         var ieInfoDataStr:String = null;
         var keyIe:String = null;
         try
         {
            date = new Date();
            o = new Object();
            o.flashVersion = Capabilities.version;
            o.flashVersion = o.flashVersion + (" (AIR " + NativeApplication.nativeApplication.runtimeVersion + ")");
            o.os = Capabilities.os;
            o.time = date.hours + ":" + date.minutes + ":" + date.seconds;
            o.date = date.date + "/" + (date.month + 1) + "/" + date.fullYear;
            o.buildType = BuildTypeParser.getTypeName(BuildInfos.BUILD_TYPE);
            o.appPath = File.applicationDirectory.nativePath;
            o.buildVersion = BuildInfos.VERSION;
            if(_logBuffer)
            {
               htmlBuffer = "";
               logs = _logBuffer.getBuffer();
               for each(log in logs)
               {
                  if(log is TextLogEvent && log.level > 0)
                  {
                     htmlBuffer = htmlBuffer + ("\t\t\t<li class=\"l_" + log.level + "\">[" + log.formattedTimestamp + "] " + log.message + "</li>\n");
                  }
               }
               o.logSos = htmlBuffer;
            }
            o.errorMsg = txt;
            if(error)
            {
               o.stacktrace = error.getStackTrace();
            }
            userNameData = File.documentsDirectory.nativePath.split(File.separator);
            o.user = userNameData[2];
            o.multicompte = !InterClientManager.getInstance().isAlone;
            if(getTimer() - _lastError > 500)
            {
               screenshot = new BitmapData(640,512,false);
               m = new Matrix();
               m.scale(0.5,0.5);
               screenshot.draw(StageShareManager.stage,m,null,null,null,true);
               o.screenshot = screenshot;
               o.mouseX = StageShareManager.mouseX;
               o.mouseY = StageShareManager.mouseY;
            }
            if(!PlayerManager.getInstance().server)
            {
               return o;
            }
            if(PlayerManager.getInstance().nickname)
            {
               o.account = PlayerManager.getInstance().nickname + " (id: " + PlayerManager.getInstance().accountId + ")";
            }
            o.accountId = PlayerManager.getInstance().accountId;
            o.serverId = PlayerManager.getInstance().server.id;
            o.server = PlayerManager.getInstance().server.name + " (id: " + PlayerManager.getInstance().server.id + ")";
            if(!PlayedCharacterManager.getInstance().infos)
            {
               return o;
            }
            o.character = PlayedCharacterManager.getInstance().infos.name + " (id: " + PlayedCharacterManager.getInstance().id + ")";
            o.characterId = PlayedCharacterManager.getInstance().id;
            currentMap = PlayedCharacterManager.getInstance().currentMap;
            if(!currentMap)
            {
               return o;
            }
            o.mapId = currentMap.mapId + " (" + currentMap.x + "/" + currentMap.y + ")";
            o.look = EntityLookAdapter.fromNetwork(PlayedCharacterManager.getInstance().infos.entityLook).toString();
            o.idMap = currentMap.mapId;
            obstacles = [];
            entities = [];
            los = [];
            fightContextFrame = this.getFightFrame();
            o.wasFighting = fightContextFrame != null;
            o.isSpectator = "";
            if(o.wasFighting)
            {
               if(PlayedCharacterManager.getInstance().isSpectator)
               {
                  o.isSpectator = "(spectateur)";
               }
               fightId = PlayedCharacterManager.getInstance().fightId;
               o.fightId = "<b>Id Combat : </b>" + fightId + "-" + currentMap.mapId;
               fighterBuffer = "";
               fighters = fightContextFrame.battleFrame.fightersList;
               for each(fighterId in fighters)
               {
                  fighterInfos = new FighterInformations(fighterId);
                  level = fightContextFrame.getFighterLevel(fighterId);
                  if(level > ProtocolConstantsEnum.MAX_LEVEL)
                  {
                     levelText = ProtocolConstantsEnum.MAX_LEVEL + " (Pr." + (level - ProtocolConstantsEnum.MAX_LEVEL) + ")";
                  }
                  else
                  {
                     levelText = "" + level;
                  }
                  fighterBuffer = fighterBuffer + ("<li><b>" + fightContextFrame.getFighterName(fighterId) + "</b>, id: " + fighterId + ", lvl: " + levelText + ", team: " + fighterInfos.team + ", vie: " + fighterInfos.lifePoints + ", pa:" + fighterInfos.actionPoints + ", pm:" + fighterInfos.movementPoints + ", cell:" + FightEntitiesFrame.getCurrentInstance().getEntityInfos(fighterId).disposition.cellId + "</li>");
               }
               o.fighterList = fighterBuffer;
               o.currentPlayer = fightContextFrame.getFighterName(this.getFightFrame().battleFrame.currentPlayerId);
            }
            if(!o.wasFighting)
            {
               entityInfoProvider = Kernel.getWorker().getFrame(RoleplayEntitiesFrame) as RoleplayEntitiesFrame;
            }
            else
            {
               entityInfoProvider = fightContextFrame.entitiesFrame;
            }
            for(cellId = 0; cellId < AtouinConstants.MAP_CELLS_COUNT; )
            {
               mp = MapPoint.fromCellId(cellId);
               obstacles.push(!!DataMapProvider.getInstance().pointMov(mp.x,mp.y,true)?1:0);
               los.push(!!DataMapProvider.getInstance().pointLos(mp.x,mp.y,true)?1:0);
               entitiesOnCell = EntitiesManager.getInstance().getEntitiesOnCell(mp.cellId);
               if(entityInfoProvider && entitiesOnCell.length)
               {
                  for each(entity in entitiesOnCell)
                  {
                     entityInfo = entityInfoProvider.getEntityInfos(entity.id);
                     entityInfoData = DescribeTypeCache.getVariables(entityInfo,true);
                     entityInfoDataStr = "{cell:" + cellId + ",className:\'" + getQualifiedClassName(entityInfo).split("::").pop() + "\'";
                     for each(key in entityInfoData)
                     {
                        if(entityInfo[key] is int || entityInfo[key] is uint || entityInfo[key] is Number || entityInfo[key] is Boolean || entityInfo[key] is String)
                        {
                           entityInfoDataStr = entityInfoDataStr + ("," + key + ":\"" + entityInfo[key] + "\"");
                        }
                     }
                     entities.push(entityInfoDataStr + "}");
                  }
               }
               cellId++;
            }
            if(!o.wasFighting && entityInfoProvider is RoleplayEntitiesFrame)
            {
               interactiveElements = entityInfoProvider.interactiveElements;
               for each(ie in interactiveElements)
               {
                  ieInfoData = DescribeTypeCache.getVariables(ie,true);
                  iePos = Atouin.getInstance().getIdentifiedElementPosition(ie.elementId);
                  ieInfoDataStr = "{cell:" + iePos.cellId + ",className:\'" + getQualifiedClassName(ie).split("::").pop() + "\'";
                  for each(keyIe in ieInfoData)
                  {
                     if(ie[keyIe] is int || ie[keyIe] is uint || ie[keyIe] is Number || ie[keyIe] is Boolean || ie[keyIe] is String)
                     {
                        ieInfoDataStr = ieInfoDataStr + ("," + keyIe + ":\"" + ie[keyIe] + "\"");
                     }
                  }
                  entities.push(ieInfoDataStr + "}");
               }
            }
            o.obstacles = obstacles.join(",");
            o.entities = entities.join(",");
            o.los = los.join(",");
         }
         catch(e:Error)
         {
            if(txt != MANUAL_BUG_REPORT_TXT)
            {
               _log.error("Error during the creation of a bug report... " + e.message + "\nInitial error :" + (!!error?error.message:txt));
            }
            else
            {
               _log.info("Manual bug report has been created");
            }
         }
         return o;
      }
      
      private function getFightFrame() : FightContextFrame
      {
         var frame:Frame = Kernel.getWorker().getFrame(FightContextFrame);
         return frame as FightContextFrame;
      }
      
      public function get localSaveReport() : Boolean
      {
         return this._localSaveReport;
      }
      
      public function get distantSaveReport() : Boolean
      {
         return this._distantSaveReport;
      }
      
      public function get sendErrorToWebservice() : Boolean
      {
         return this._sendErrorToWebservice;
      }
   }
}
