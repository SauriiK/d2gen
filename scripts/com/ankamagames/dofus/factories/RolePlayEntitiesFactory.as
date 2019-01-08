package com.ankamagames.dofus.factories
{
   import com.ankamagames.atouin.managers.EntitiesManager;
   import com.ankamagames.dofus.internalDatacenter.conquest.PrismSubAreaWrapper;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.logic.game.common.frames.AllianceFrame;
   import com.ankamagames.dofus.logic.game.common.managers.PlayedCharacterManager;
   import com.ankamagames.dofus.network.enums.AlignmentSideEnum;
   import com.ankamagames.dofus.network.enums.FightTypeEnum;
   import com.ankamagames.dofus.network.enums.TeamEnum;
   import com.ankamagames.dofus.network.enums.TeamTypeEnum;
   import com.ankamagames.dofus.network.types.game.context.fight.FightCommonInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.FightTeamInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.FightTeamMemberWithAllianceCharacterInformations;
   import com.ankamagames.dofus.types.entities.AnimatedCharacter;
   import com.ankamagames.jerakine.entities.interfaces.IAnimated;
   import com.ankamagames.jerakine.entities.interfaces.IEntity;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.types.positions.MapPoint;
   import com.ankamagames.tiphon.types.look.TiphonEntityLook;
   import flash.utils.getQualifiedClassName;
   
   public class RolePlayEntitiesFactory
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(RolePlayEntitiesFactory));
      
      private static const TEAM_CHALLENGER_LOOK:String = "{19}";
      
      private static const TEAM_DEFENDER_LOOK:String = "{20}";
      
      private static const TEAM_TAX_COLLECTOR_LOOK:String = "{21}";
      
      private static const TEAM_ANGEL_LOOK:String = "{32}";
      
      private static const TEAM_DEMON_LOOK:String = "{33}";
      
      private static const TEAM_NEUTRAL_LOOK:String = "{1237}";
      
      private static const TEAM_BAD_ANGEL_LOOK:String = "{1235}";
      
      private static const TEAM_BAD_DEMON_LOOK:String = "{1236}";
      
      private static const TEAM_CHALLENGER_AVA_ALLY:String = "{2248}";
      
      private static const TEAM_CHALLENGER_AVA_ATTACKERS:String = "{2249}";
      
      private static const TEAM_CHALLENGER_AVA_DEFENDERS:String = "{2251}";
      
      private static const TEAM_DEFENDER_AVA_ALLY:String = "{2252}";
      
      private static const TEAM_DEFENDER_AVA_ATTACKERS:String = "{2253}";
      
      private static const TEAM_DEFENDER_AVA_DEFENDERS:String = "{2255}";
       
      
      public function RolePlayEntitiesFactory()
      {
         super();
      }
      
      public static function createFightEntity(fightInfos:FightCommonInformations, teamInfos:FightTeamInformations, position:MapPoint, fightColor:int) : IEntity
      {
         var teamLook:* = null;
         var allianceFrame:* = null;
         var playerAllianceId:Number = NaN;
         var teamAllianceId:int = 0;
         var prismSubAreaInfo:* = null;
         var prismAllianceId:int = 0;
         var entityId:Number = EntitiesManager.getInstance().getFreeEntityId();
         loop0:
         switch(fightInfos.fightType)
         {
            case FightTypeEnum.FIGHT_TYPE_AGRESSION:
               switch(teamInfos.teamSide)
               {
                  case AlignmentSideEnum.ALIGNMENT_ANGEL:
                     if(teamInfos.teamTypeId == TeamTypeEnum.TEAM_TYPE_BAD_PLAYER)
                     {
                        teamLook = TEAM_BAD_ANGEL_LOOK;
                        break loop0;
                     }
                     teamLook = TEAM_ANGEL_LOOK;
                     break loop0;
                  case AlignmentSideEnum.ALIGNMENT_EVIL:
                     if(teamInfos.teamTypeId == TeamTypeEnum.TEAM_TYPE_BAD_PLAYER)
                     {
                        teamLook = TEAM_BAD_DEMON_LOOK;
                        break loop0;
                     }
                     teamLook = TEAM_DEMON_LOOK;
                     break loop0;
                  case AlignmentSideEnum.ALIGNMENT_NEUTRAL:
                     teamLook = TEAM_NEUTRAL_LOOK;
                     break loop0;
                  case AlignmentSideEnum.ALIGNMENT_WITHOUT:
                     teamLook = TEAM_CHALLENGER_LOOK;
                     break loop0;
                  default:
                     break loop0;
               }
            case FightTypeEnum.FIGHT_TYPE_Koh:
               allianceFrame = Kernel.getWorker().getFrame(AllianceFrame) as AllianceFrame;
               playerAllianceId = !!allianceFrame.hasAlliance?Number(allianceFrame.alliance.allianceId):Number(-1);
               if(teamInfos.teamMembers[0] is FightTeamMemberWithAllianceCharacterInformations)
               {
                  teamAllianceId = (teamInfos.teamMembers[0] as FightTeamMemberWithAllianceCharacterInformations).allianceInfos.allianceId;
               }
               prismSubAreaInfo = allianceFrame.getPrismSubAreaById(PlayedCharacterManager.getInstance().currentSubArea.id);
               prismAllianceId = !!prismSubAreaInfo?!!prismSubAreaInfo.alliance?int(prismSubAreaInfo.alliance.allianceId):int(playerAllianceId):-1;
               switch(teamInfos.teamId)
               {
                  case TeamEnum.TEAM_DEFENDER:
                     if(playerAllianceId != -1 && playerAllianceId == teamAllianceId)
                     {
                        teamLook = TEAM_DEFENDER_AVA_ALLY;
                        break loop0;
                     }
                     if(prismAllianceId != -1)
                     {
                        if(teamAllianceId == prismAllianceId)
                        {
                           teamLook = TEAM_DEFENDER_AVA_DEFENDERS;
                           break loop0;
                        }
                        teamLook = TEAM_DEFENDER_AVA_ATTACKERS;
                        break loop0;
                     }
                     teamLook = TEAM_DEFENDER_AVA_ATTACKERS;
                     break loop0;
                  case TeamEnum.TEAM_CHALLENGER:
                     if(playerAllianceId != -1 && playerAllianceId == teamAllianceId)
                     {
                        teamLook = TEAM_CHALLENGER_AVA_ALLY;
                        break loop0;
                     }
                     if(prismAllianceId != -1)
                     {
                        if(teamAllianceId == prismAllianceId)
                        {
                           teamLook = TEAM_CHALLENGER_AVA_DEFENDERS;
                           break loop0;
                        }
                        teamLook = TEAM_CHALLENGER_AVA_ATTACKERS;
                        break loop0;
                     }
                     teamLook = TEAM_CHALLENGER_AVA_ATTACKERS;
                     break loop0;
                  default:
                     break loop0;
               }
            case FightTypeEnum.FIGHT_TYPE_PvT:
               switch(teamInfos.teamId)
               {
                  case TeamEnum.TEAM_DEFENDER:
                     teamLook = TEAM_TAX_COLLECTOR_LOOK;
                     break loop0;
                  case TeamEnum.TEAM_CHALLENGER:
                     teamLook = TEAM_CHALLENGER_LOOK;
                     break loop0;
                  default:
                     break loop0;
               }
            case FightTypeEnum.FIGHT_TYPE_CHALLENGE:
               teamLook = TEAM_CHALLENGER_LOOK;
               break;
            default:
               switch(teamInfos.teamId)
               {
                  case TeamEnum.TEAM_CHALLENGER:
                     teamLook = TEAM_CHALLENGER_LOOK;
                     break loop0;
                  case TeamEnum.TEAM_DEFENDER:
                     teamLook = TEAM_DEFENDER_LOOK;
                     break loop0;
                  default:
                     break loop0;
               }
         }
         teamLook = teamLook.replace("}","||1=" + fightColor + "}");
         var challenger:IEntity = new AnimatedCharacter(entityId,TiphonEntityLook.fromString(teamLook));
         challenger.position = position;
         IAnimated(challenger).setDirection(0);
         return challenger;
      }
   }
}
