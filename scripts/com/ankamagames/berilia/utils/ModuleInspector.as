package com.ankamagames.berilia.utils
{
   import by.blooddy.crypto.MD5;
   import com.ankamagames.berilia.BeriliaConstants;
   import com.ankamagames.berilia.managers.UiModuleManager;
   import com.ankamagames.jerakine.managers.StoreDataManager;
   import com.ankamagames.jerakine.resources.adapters.impl.SignedFileAdapter;
   import com.ankamagames.jerakine.utils.crypto.Signature;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import nochump.util.zip.ZipEntry;
   import nochump.util.zip.ZipFile;
   import org.as3commons.bytecode.abc.AbcFile;
   import org.as3commons.bytecode.abc.ClassInfo;
   import org.as3commons.bytecode.swf.SWFFile;
   import org.as3commons.bytecode.swf.SWFFileIO;
   import org.as3commons.bytecode.tags.DoABCTag;
   import org.as3commons.bytecode.tags.FileAttributesTag;
   
   public class ModuleInspector
   {
      
      public static const whiteList:Array = new Array("dm","swf","xml","txt","png","jpg","css");
       
      
      public function ModuleInspector()
      {
         super();
      }
      
      public static function checkArchiveValidity(archive:ZipFile) : Boolean
      {
         var entry:* = null;
         var dotIndex:int = 0;
         var fileType:* = null;
         var totalSize:int = 0;
         for each(entry in archive.entries)
         {
            dotIndex = entry.name.lastIndexOf(".");
            fileType = entry.name.substring(dotIndex + 1);
            if(!entry.isDirectory() && whiteList.indexOf(fileType) == -1)
            {
               return false;
            }
            totalSize = totalSize + entry.size;
         }
         return totalSize < ModuleFileManager.MAX_FILE_SIZE && archive.size < ModuleFileManager.MAX_FILE_NUM;
      }
      
      public static function getDmFile(targetFile:File) : XML
      {
         var entry:* = null;
         var dmData:* = null;
         var rfs:* = null;
         var rawData:ByteArray = new ByteArray();
         if(targetFile.exists)
         {
            for each(entry in targetFile.getDirectoryListing())
            {
               if(!entry.isDirectory)
               {
                  if(entry.type == ".dm")
                  {
                     if(entry.name.lastIndexOf("/") != -1)
                     {
                        return null;
                     }
                     rfs = new FileStream();
                     rfs.open(File(entry),FileMode.READ);
                     rfs.readBytes(rawData,0,rfs.bytesAvailable);
                     rfs.close();
                     dmData = new XML(rawData.readUTFBytes(rawData.bytesAvailable));
                     return dmData;
                  }
               }
            }
         }
         return null;
      }
      
      public static function getZipDmFile(targetFile:ZipFile) : XML
      {
         var entry:* = null;
         var dmData:* = null;
         var dotIndex:int = 0;
         var fileType:* = null;
         var rawData:ByteArray = new ByteArray();
         for each(entry in targetFile.entries)
         {
            if(!entry.isDirectory())
            {
               dotIndex = entry.name.lastIndexOf(".");
               fileType = entry.name.substring(dotIndex + 1);
               if(fileType.toLowerCase() == "dm")
               {
                  if(entry.name.lastIndexOf("/") != -1)
                  {
                     return null;
                  }
                  rawData = ZipFile(targetFile).getInput(entry);
                  dmData = new XML(rawData.readUTFBytes(rawData.bytesAvailable));
                  return dmData;
               }
            }
         }
         return null;
      }
      
      public static function isModuleEnabled(moduleId:String, trusted:Boolean) : Boolean
      {
         var enable:Boolean = false;
         var state:* = StoreDataManager.getInstance().getData(BeriliaConstants.DATASTORE_MOD,moduleId);
         if(state == null)
         {
            enable = trusted;
         }
         else
         {
            enable = state || trusted;
         }
         return enable;
      }
      
      public static function checkIfModuleTrusted(filePath:String) : Boolean
      {
         var fs:* = null;
         var swfContent:* = null;
         var fooOutput:* = null;
         var sig:* = null;
         var scriptFile:File = new File(filePath);
         var modulesHashs:Dictionary = UiModuleManager.getInstance().modulesHashs;
         if(scriptFile.exists)
         {
            fs = new FileStream();
            fs.open(scriptFile,FileMode.READ);
            swfContent = new ByteArray();
            fs.readBytes(swfContent);
            fs.close();
            if(scriptFile.type == ".swf")
            {
               return MD5.hashBytes(swfContent) == modulesHashs[scriptFile.name];
            }
            if(scriptFile.type == ".swfs")
            {
               fooOutput = new ByteArray();
               sig = new Signature(SignedFileAdapter.defaultSignatureKey);
               return sig.verify(swfContent,fooOutput);
            }
         }
         return false;
      }
      
      public static function getScriptHookAndApis(swfContent:ByteArray) : Object
      {
         var tag:* = null;
         var abcFile:* = null;
         var infos:* = null;
         var attributesTag:* = null;
         var fileAttributesTags:* = null;
         var apiHookAction:* = new Object();
         var io:SWFFileIO = new SWFFileIO();
         var swfFile:SWFFile = io.read(swfContent);
         apiHookAction.apis = new Array();
         apiHookAction.hooks = new Array();
         for each(tag in swfFile.getTagsByType(DoABCTag))
         {
            abcFile = tag.abcFile;
            for each(infos in abcFile.classInfo)
            {
               switch(infos.classMultiname.nameSpace.name)
               {
                  case "d2hooks":
                     apiHookAction.hooks.push(infos.classMultiname.name);
                     continue;
                  case "d2api":
                     apiHookAction.apis.push(infos.classMultiname.name);
                     continue;
                  default:
                     continue;
               }
            }
         }
         fileAttributesTags = swfFile.getTagsByType(FileAttributesTag);
         for each(attributesTag in fileAttributesTags)
         {
            apiHookAction.useNetwork = attributesTag.useNetwork;
         }
         return apiHookAction;
      }
   }
}
