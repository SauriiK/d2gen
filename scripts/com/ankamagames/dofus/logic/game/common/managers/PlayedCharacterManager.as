package com.ankamagames.dofus.logic.game.common.managers
{
   import com.ankamagames.dofus.datacenter.breeds.Breed;
   import com.ankamagames.dofus.datacenter.world.SubArea;
   import com.ankamagames.dofus.datacenter.world.WorldMap;
   import com.ankamagames.dofus.internalDatacenter.DataEnum;
   import com.ankamagames.dofus.internalDatacenter.items.IdolsPresetWrapper;
   import com.ankamagames.dofus.internalDatacenter.items.ItemWrapper;
   import com.ankamagames.dofus.internalDatacenter.items.WeaponWrapper;
   import com.ankamagames.dofus.internalDatacenter.mount.MountData;
   import com.ankamagames.dofus.internalDatacenter.world.WorldPointWrapper;
   import com.ankamagames.dofus.misc.EntityLookAdapter;
   import com.ankamagames.dofus.misc.stats.StatisticsManager;
   import com.ankamagames.dofus.misc.utils.CharacterIdConverter;
   import com.ankamagames.dofus.network.ProtocolConstantsEnum;
   import com.ankamagames.dofus.network.enums.CharacterInventoryPositionEnum;
   import com.ankamagames.dofus.network.enums.SubEntityBindingPointCategoryEnum;
   import com.ankamagames.dofus.network.types.game.character.characteristic.CharacterCharacteristicsInformations;
   import com.ankamagames.dofus.network.types.game.character.choice.CharacterBaseInformations;
   import com.ankamagames.dofus.network.types.game.character.restriction.ActorRestrictionsInformations;
   import com.ankamagames.dofus.network.types.game.look.EntityLook;
   import com.ankamagames.jerakine.interfaces.IDestroyable;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.types.Callback;
   import com.ankamagames.jerakine.utils.errors.SingletonError;
   import com.ankamagames.tiphon.types.look.TiphonEntityLook;
   import flash.geom.Point;
   import flash.utils.getQualifiedClassName;
   
   public class PlayedCharacterManager implements IDestroyable
   {
      
      private static var _self:PlayedCharacterManager;
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(PlayedCharacterManager));
       
      
      private var _isPartyLeader:Boolean = false;
      
      private var _followingPlayerIds:Vector.<Number>;
      
      private var _soloIdols:Vector.<uint>;
      
      private var _partyIdols:Vector.<uint>;
      
      private var _idolsPresets:Vector.<IdolsPresetWrapper>;
      
      private var _infosAvailableCallbacks:Vector.<Callback>;
      
      private var _infos:CharacterBaseInformations;
      
      public var restrictions:ActorRestrictionsInformations;
      
      public var realEntityLook:EntityLook;
      
      public var characteristics:CharacterCharacteristicsInformations;
      
      public var spellsInventory:Array;
      
      public var playerSpellList:Array;
      
      public var playerShortcutList:Array;
      
      public var inventory:Vector.<ItemWrapper>;
      
      public var currentWeapon:WeaponWrapper;
      
      public var inventoryWeight:uint;
      
      public var inventoryWeightMax:uint;
      
      public var currentMap:WorldPointWrapper;
      
      public var currentSubArea:SubArea;
      
      public var jobs:Array;
      
      public var isInExchange:Boolean = false;
      
      public var isInHisHouse:Boolean = false;
      
      public var isInHouse:Boolean = false;
      
      public var isInHisHavenbag:Boolean = false;
      
      public var isInHavenbag:Boolean = false;
      
      public var currentHavenbagTotalRooms:uint;
      
      public var lastCoord:Point;
      
      public var isInParty:Boolean = false;
      
      public var state:uint;
      
      public var publicMode:Boolean = false;
      
      public var isRidding:Boolean = false;
      
      public var isPetsMounting:Boolean = false;
      
      public var hasCompanion:Boolean = false;
      
      public var mount:MountData;
      
      public var isFighting:Boolean = false;
      
      public var fightId:int = -1;
      
      public var teamId:int = 0;
      
      public var isSpectator:Boolean = false;
      
      public var experiencePercent:int = 0;
      
      public var achievementPoints:int = 0;
      
      public var achievementPercent:int = 0;
      
      public var waitingGifts:Array;
      
      public function PlayedCharacterManager()
      {
         this._followingPlayerIds = new Vector.<Number>();
         this._soloIdols = new Vector.<uint>();
         this._partyIdols = new Vector.<uint>();
         this._idolsPresets = new Vector.<IdolsPresetWrapper>(0);
         this._infosAvailableCallbacks = new Vector.<Callback>(0);
         this.lastCoord = new Point(0,0);
         this.waitingGifts = new Array();
         super();
         if(_self != null)
         {
            throw new SingletonError("PlayedCharacterManager is a singleton and should not be instanciated directly.");
         }
      }
      
      public static function getInstance() : PlayedCharacterManager
      {
         if(_self == null)
         {
            _self = new PlayedCharacterManager();
         }
         return _self;
      }
      
      public function get id() : Number
      {
         if(this.infos)
         {
            return this.infos.id;
         }
         return 0;
      }
      
      public function set id(id:Number) : void
      {
         if(this.infos)
         {
            this.infos.id = id;
         }
      }
      
      public function get infos() : CharacterBaseInformations
      {
         return this._infos;
      }
      
      public function set infos(pInfos:CharacterBaseInformations) : void
      {
         var callback:* = null;
         this._infos = pInfos;
         for each(callback in this._infosAvailableCallbacks)
         {
            callback.exec();
         }
      }
      
      public function get cantMinimize() : Boolean
      {
         return this.restrictions.cantMinimize;
      }
      
      public function get forceSlowWalk() : Boolean
      {
         return this.restrictions.forceSlowWalk;
      }
      
      public function get cantUseTaxCollector() : Boolean
      {
         return this.restrictions.cantUseTaxCollector;
      }
      
      public function get cantTrade() : Boolean
      {
         return this.restrictions.cantTrade;
      }
      
      public function get cantRun() : Boolean
      {
         return this.restrictions.cantRun;
      }
      
      public function get cantMove() : Boolean
      {
         return this.restrictions.cantMove;
      }
      
      public function get cantBeChallenged() : Boolean
      {
         return this.restrictions.cantBeChallenged;
      }
      
      public function get cantBeAttackedByMutant() : Boolean
      {
         return this.restrictions.cantBeAttackedByMutant;
      }
      
      public function get cantBeAggressed() : Boolean
      {
         return this.restrictions.cantBeAggressed;
      }
      
      public function get cantAttack() : Boolean
      {
         return this.restrictions.cantAttack;
      }
      
      public function get cantAgress() : Boolean
      {
         return this.restrictions.cantAggress;
      }
      
      public function get cantChallenge() : Boolean
      {
         return this.restrictions.cantChallenge;
      }
      
      public function get cantExchange() : Boolean
      {
         return this.restrictions.cantExchange;
      }
      
      public function get cantChat() : Boolean
      {
         return this.restrictions.cantChat;
      }
      
      public function get cantBeMerchant() : Boolean
      {
         return this.restrictions.cantBeMerchant;
      }
      
      public function get cantUseObject() : Boolean
      {
         return this.restrictions.cantUseObject;
      }
      
      public function get cantUseInteractiveObject() : Boolean
      {
         return this.restrictions.cantUseInteractive;
      }
      
      public function get cantSpeakToNpc() : Boolean
      {
         return this.restrictions.cantSpeakToNPC;
      }
      
      public function get cantChangeZone() : Boolean
      {
         return this.restrictions.cantChangeZone;
      }
      
      public function get cantAttackMonster() : Boolean
      {
         return this.restrictions.cantAttackMonster;
      }
      
      public function get cantWalkInEightDirections() : Boolean
      {
         return this.restrictions.cantWalk8Directions;
      }
      
      public function get limitedLevel() : uint
      {
         if(this.infos)
         {
            if(this.infos.level > ProtocolConstantsEnum.MAX_LEVEL)
            {
               return ProtocolConstantsEnum.MAX_LEVEL;
            }
            return this.infos.level;
         }
         return 0;
      }
      
      public function get currentWorldMap() : WorldMap
      {
         if(this.currentSubArea)
         {
            return this.currentSubArea.worldmap;
         }
         return null;
      }
      
      public function get currentWorldMapId() : int
      {
         if(this.currentSubArea && this.currentSubArea.worldmap)
         {
            return this.currentSubArea.worldmap.id;
         }
         return -1;
      }
      
      public function get isIncarnation() : Boolean
      {
         return EntitiesLooksManager.getInstance().isIncarnation(this.id);
      }
      
      public function get isMutated() : Boolean
      {
         var l:int = 0;
         var i:int = 0;
         var rpBuffs:Vector.<ItemWrapper> = InventoryManager.getInstance().inventory.getView("roleplayBuff").content;
         if(rpBuffs)
         {
            l = rpBuffs.length;
            for(i = 0; i < l; )
            {
               if(rpBuffs[i] && rpBuffs[i].typeId == DataEnum.ITEM_TYPE_MUTATIONS && rpBuffs[i].position == CharacterInventoryPositionEnum.INVENTORY_POSITION_MUTATION)
               {
                  return true;
               }
               i++;
            }
         }
         return false;
      }
      
      public function set isPartyLeader(b:Boolean) : void
      {
         if(!this.isInParty)
         {
            this._isPartyLeader = false;
         }
         else
         {
            this._isPartyLeader = b;
         }
      }
      
      public function get isPartyLeader() : Boolean
      {
         return this._isPartyLeader;
      }
      
      public function get isGhost() : Boolean
      {
         var breed:* = null;
         var look:TiphonEntityLook = EntityLookAdapter.fromNetwork(this.infos.entityLook);
         var isCreature:Boolean = false;
         var breeds:Array = Breed.getBreeds();
         for each(breed in breeds)
         {
            if(breed.creatureBonesId == look.getBone())
            {
               isCreature = true;
               break;
            }
         }
         return !look.getSubEntity(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_MOUNT_DRIVER,0) && !isCreature && look.getBone() != 1 && !this.isIncarnation;
      }
      
      public function get artworkId() : uint
      {
         return this.infos.entityLook.bonesId == 1?uint(this.infos.entityLook.skins[0]):uint(this.infos.entityLook.bonesId);
      }
      
      public function get followingPlayerIds() : Vector.<Number>
      {
         return this._followingPlayerIds;
      }
      
      public function set followingPlayerIds(pPlayerIds:Vector.<Number>) : void
      {
         this._followingPlayerIds = pPlayerIds;
      }
      
      public function get soloIdols() : Vector.<uint>
      {
         return this._soloIdols;
      }
      
      public function set soloIdols(pIdols:Vector.<uint>) : void
      {
         this._soloIdols = pIdols;
      }
      
      public function get partyIdols() : Vector.<uint>
      {
         return this._partyIdols;
      }
      
      public function set partyIdols(pIdols:Vector.<uint>) : void
      {
         this._partyIdols = pIdols;
      }
      
      public function get idolsPresets() : Vector.<IdolsPresetWrapper>
      {
         return this._idolsPresets;
      }
      
      public function set idolsPresets(pIdolsPresets:Vector.<IdolsPresetWrapper>) : void
      {
         this._idolsPresets = pIdolsPresets;
      }
      
      public function get extractedServerCharacterIdFromInterserverCharacterId() : Number
      {
         return CharacterIdConverter.extractServerCharacterIdFromInterserverCharacterId(this.id);
      }
      
      public function get canBeAggressedByMonsters() : Boolean
      {
         if(this.characteristics.energyPoints == 0)
         {
            return false;
         }
         if(this.restrictions.cantAttackMonster)
         {
            return false;
         }
         return true;
      }
      
      public function destroy() : void
      {
         _self = null;
         StatisticsManager.getInstance().removeStats("shortcuts");
      }
      
      public function get tiphonEntityLook() : TiphonEntityLook
      {
         return EntityLookAdapter.fromNetwork(this.infos.entityLook);
      }
      
      public function levelDiff(targetLevel:uint) : int
      {
         var diff:int = 0;
         var playerLevel:int = this.limitedLevel;
         if(targetLevel > ProtocolConstantsEnum.MAX_LEVEL)
         {
            targetLevel = ProtocolConstantsEnum.MAX_LEVEL;
         }
         var type:int = 1;
         if(targetLevel < playerLevel)
         {
            type = -1;
         }
         if(Math.abs(targetLevel - playerLevel) > 20)
         {
            diff = 1 * type;
         }
         else if(targetLevel > playerLevel)
         {
            if(targetLevel / playerLevel < 1.2)
            {
               diff = 0;
            }
            else
            {
               diff = 1 * type;
            }
         }
         else if(playerLevel / targetLevel < 1.2)
         {
            diff = 0;
         }
         else
         {
            diff = 1 * type;
         }
         return diff;
      }
      
      public function addInfosAvailableCallback(pCallback:Callback) : void
      {
         this._infosAvailableCallbacks.push(pCallback);
      }
   }
}
