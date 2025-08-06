package
{
   import Shared.AS3.BSScrollingList;
   import Shared.AS3.IMenu;
   import Shared.AS3.StyleSheet;
   import Shared.AS3.Styles.Terminal_MenuItemListStyle;
   import Shared.GlobalFunc;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextLineMetrics;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import scaleform.gfx.Extensions;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol22")]
   public class Terminal extends IMenu
   {
      
      public var HeaderText_tf:TextField;
      
      public var WelcomeText_tf:TextField;
      
      public var DisplayText_tf:TextField;
      
      public var ResponsePrompt_tf:TextField;
      
      public var ResponseText_tf:TextField;
      
      public var ResponseLog_tf:TextField;
      
      public var HackingAttempts_tf:TextField;
      
      public var MenuItemList_mc:MenuItemList;
      
      public var BlinkingCursor_mc:MovieClip;
      
      public var HackingHighlight1_mc:MovieClip;
      
      public var HackingHighlight2_mc:MovieClip;
      
      public var HackingGuess1_mc:MovieClip;
      
      public var HackingGuess2_mc:MovieClip;
      
      public var HackingGuess3_mc:MovieClip;
      
      public var HackingGuess4_mc:MovieClip;
      
      public var HackingGuess5_mc:MovieClip;
      
      public var BGSCodeObj:Object;
      
      public var strHeaderText:String;
      
      public var strWelcomeText:String;
      
      public var strDisplayText:String;
      
      public var strResponseText:String;
      
      public var textUpdateTimer:Timer;
      
      public var responseUpdateTimer:Timer;
      
      public var attemptUpdateTimer:Timer;
      
      public var iTickCount:int = 0;
      
      public var bAnimateDisplayText:Boolean;
      
      public var bShowHackingAttempts:Boolean;
      
      protected var bAcceptDebounce:Boolean;
      
      public var displayText_x:Number;
      
      public var displayText_y:Number;
      
      public var displayText_width:Number;
      
      public var displayText_height:Number;
      
      public var responsePrompt_x:Number;
      
      public var responsePrompt_y:Number;
      
      public var responseText_x:Number;
      
      public var responseText_y:Number;
      
      public var responseText_width:Number;
      
      public var displayTextMenuBuffer_y:Number = 10;
      
      public var menuItemList_y:Number;
      
      public var menuItemList_height:Number;
      
      public var menuItemList_scrollDownY:Number;
      
      public var displayText_startChar:Number = 0;
      
      public var displayText_isDone:Boolean = false;
      
      public var DisplayImage_mc:MovieClip;
      
      private var DisplayImageLoader:Loader;
      
      private var ncharRemainder:* = 0;
      
      private var ucharsPerSec:uint = 10000;
      
      private var hackingHighlightQueued:Boolean = false;
      
      private var queuedHackingHighlightCharIndex1:int;
      
      private var queuedHackingHighlightText1:String;
      
      private var queuedHackingHighlightCharIndex2:int;
      
      private var queuedHackingHighlightText2:String;
      
      private var isHacking:Boolean = false;
      
      private var attempts:Array = [];
      
      private var attemptWords:Object = {};
      
      private var isUpdating:Boolean = false;
      
      public function Terminal()
      {
         super();
         this.BGSCodeObj = new Object();
         this.strHeaderText = new String();
         this.strWelcomeText = new String();
         this.strDisplayText = new String();
         this.strResponseText = new String();
         this.textUpdateTimer = new Timer(33);
         this.responseUpdateTimer = new Timer(33);
         this.attemptUpdateTimer = new Timer(33);
         GlobalFunc.MaintainTextFormat();
         stage.stageFocusRect = false;
         this.bAnimateDisplayText = false;
         this.bAcceptDebounce = false;
         StyleSheet.apply(this.MenuItemList_mc,false,Terminal_MenuItemListStyle);
         this.MenuItemList_mc.disableInput_Inspectable = true;
         addEventListener(BSScrollingList.SELECTION_CHANGE,this.playSelectSound);
         addEventListener(BSScrollingList.ITEM_PRESS,this.onItemPress);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseClick);
         this.HackingHighlight1_mc.visible = false;
         this.HackingHighlight2_mc.visible = false;
         this.ResponsePrompt_tf.visible = false;
         this.ResponseLog_tf.visible = false;
         this.HackingAttempts_tf.visible = false;
         this.bShowHackingAttempts = false;
         this.ShowHackingGuesses(false);
         this.menuItemList_y = this.MenuItemList_mc.y;
         this.menuItemList_height = this.MenuItemList_mc.border.height;
         this.menuItemList_scrollDownY = this.MenuItemList_mc.ScrollDown.y;
         var _loc1_:MovieClip = this.MenuItemList_mc.border as MovieClip;
         var _loc2_:MovieClip = this.MenuItemList_mc.EntryHolder_mc as MovieClip;
         _loc2_.mask = _loc1_;
         this.ncharRemainder = 0;
         Extensions.enabled = true;
         ShrinkFontToFit(this.HackingAttempts_tf,1);
         this.DisplayText_tf.text = " ";
      }
      
      public function onCodeObjCreate() : *
      {
         if(false)
         {
            this.ucharsPerSec = this.BGSCodeObj.GetDisplayRate();
         }
      }
      
      public function playSelectSound() : *
      {
         this.BGSCodeObj.PlaySound("UITerminalCharArrow");
      }
      
      public function RegisterTerminalElements() : *
      {
         this.displayText_x = this.DisplayText_tf.x;
         this.displayText_y = this.DisplayText_tf.y;
         this.displayText_width = this.DisplayText_tf.width;
         this.displayText_height = this.DisplayText_tf.height;
         this.responsePrompt_x = this.ResponsePrompt_tf.x;
         this.responsePrompt_y = this.ResponsePrompt_tf.y;
         this.responseText_x = this.ResponseText_tf.x;
         this.responseText_y = this.ResponseText_tf.y;
         this.responseText_width = this.ResponseText_tf.width;
         this.BGSCodeObj.RegisterTerminalElements(this.HeaderText_tf,this.WelcomeText_tf,this.DisplayText_tf,this.ResponseText_tf,this.MenuItemList_mc,this.DisplayImage_mc);
         this.textUpdateTimer.addEventListener(TimerEvent.TIMER,function():*
         {
            UpdateText();
         });
         this.responseUpdateTimer.addEventListener(TimerEvent.TIMER,function():*
         {
            UpdateResponseText();
         });
         this.attemptUpdateTimer.addEventListener(TimerEvent.TIMER,function():*
         {
            updateAttempts();
         });
         this.attemptUpdateTimer.start();
         this.HackingHighlight1_mc.HackingHighlightText_tf.addEventListener(MouseEvent.CLICK,this.onTextClick);
         this.HackingHighlight2_mc.HackingHighlightText_tf.addEventListener(MouseEvent.CLICK,this.onTextClick);
         this.DisplayText_tf.addEventListener(MouseEvent.MOUSE_MOVE,this.onTextOver);
         this.HackingHighlight1_mc.HackingHighlightText_tf.addEventListener(MouseEvent.MOUSE_MOVE,this.onTextOver);
         this.HackingHighlight2_mc.HackingHighlightText_tf.addEventListener(MouseEvent.MOUSE_MOVE,this.onTextOver);
         this.StartTextTimer();
      }
      
      public function DisplayHack(param1:TextField) : *
      {
         param1.x = param1.x;
      }
      
      public function onTextOver(param1:Event) : void
      {
         if(this.isUpdating)
         {
            return;
         }
         var _loc3_:int = 0;
         var _loc2_:int = this.DisplayText_tf.getCharIndexAtPoint(this.DisplayText_tf.mouseX,this.DisplayText_tf.mouseY);
         if(_loc2_ >= 0)
         {
            _loc3_ = this.DisplayText_tf.getLineIndexOfChar(_loc2_);
            this.BGSCodeObj.SelectHackingWord(_loc2_,_loc3_);
         }
      }
      
      public function onTextClick(param1:Event) : void
      {
         this.BGSCodeObj.ValidateHackingWord();
      }
      
      public function ConvertToGlobal(param1:TextField) : Point
      {
         var _loc2_:Rectangle = new Rectangle();
         var _loc3_:Point = new Point();
         var _loc4_:Boolean = false;
         var _loc5_:int = param1.length - 1;
         while(_loc5_ >= 0)
         {
            _loc4_ = param1.text.charCodeAt(_loc5_) != 13 && param1.text.charCodeAt(_loc5_) != 10 && (param1.text.charCodeAt(_loc5_) != 32 || param1.length > 1);
            if(_loc4_)
            {
               break;
            }
            _loc5_--;
         }
         if(_loc4_)
         {
            _loc2_ = param1.getCharBoundaries(_loc5_);
            _loc3_.x = _loc2_.bottomRight.x;
            _loc3_.y = _loc2_.y;
         }
         return param1.localToGlobal(_loc3_);
      }
      
      public function UpdateTextField(param1:TextField, param2:String, param3:uint, param4:Boolean) : *
      {
         if(param4 || param1.length + param3 >= param2.length)
         {
            GlobalFunc.SetText(param1,param2,false);
         }
         else
         {
            GlobalFunc.SetText(param1,param2.slice(0,param1.length + param3),false);
         }
      }
      
      public function UpdateText(param1:Boolean = false) : *
      {
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:uint = 0;
         var _loc7_:Boolean = false;
         var _loc8_:uint = 0;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:uint = 0;
         var _loc12_:uint = 0;
         var _loc13_:TextLineMetrics = null;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc2_:Point = new Point(-1,-1);
         if(!this.responseUpdateTimer.running)
         {
            _loc3_ = this.iTickCount;
            this.iTickCount = getTimer();
            this.ncharRemainder += (_loc6_ = (_loc4_ = (this.iTickCount - _loc3_) / 1000) * this.ucharsPerSec) - _loc6_;
            if(this.ncharRemainder > 1)
            {
               _loc6_ += 1;
               --this.ncharRemainder;
            }
            this.visible = true;
            if(this.MenuItemList_mc.y != this.menuItemList_y || this.MenuItemList_mc.border.height != this.menuItemList_height || this.MenuItemList_mc.ScrollDown.y != this.menuItemList_scrollDownY)
            {
               this.MenuItemList_mc.y = this.menuItemList_y;
               this.MenuItemList_mc.border.height = this.menuItemList_height;
               this.MenuItemList_mc.ScrollDown.y = this.menuItemList_scrollDownY;
               this.MenuItemList_mc.InvalidateData();
            }
            _loc7_ = true;
            this.MenuItemList_mc.disableInput_Inspectable = true;
            if(this.HeaderText_tf.length < this.strHeaderText.length)
            {
               this.UpdateTextField(this.HeaderText_tf,this.strHeaderText,_loc6_,param1);
               this.DisplayHack(this.HeaderText_tf);
               _loc7_ = param1;
               _loc2_ = this.ConvertToGlobal(this.HeaderText_tf);
            }
            if(_loc7_ && this.WelcomeText_tf.length < this.strWelcomeText.length)
            {
               this.UpdateTextField(this.WelcomeText_tf,this.strWelcomeText,_loc6_,param1);
               this.DisplayHack(this.WelcomeText_tf);
               _loc7_ = param1;
               _loc2_ = this.ConvertToGlobal(this.WelcomeText_tf);
            }
            if(_loc7_ && this.bAnimateDisplayText)
            {
               _loc8_ = 0;
               _loc9_ = !param1 && _loc8_ >= _loc6_;
               _loc10_ = param1;
               _loc11_ = 1;
               while(!_loc9_)
               {
                  _loc12_ = uint(this.DisplayText_tf.length);
                  GlobalFunc.SetText(this.DisplayText_tf,this.strDisplayText.slice(this.displayText_startChar,this.displayText_startChar + this.DisplayText_tf.length + _loc11_),false);
                  _loc13_ = this.DisplayText_tf.getLineMetrics(this.DisplayText_tf.numLines - 1);
                  if(_loc12_ == this.DisplayText_tf.length)
                  {
                     _loc11_ += 1;
                  }
                  else
                  {
                     _loc11_ = 1;
                  }
                  if(this.displayText_startChar + this.DisplayText_tf.length >= this.strDisplayText.length)
                  {
                     _loc9_ = true;
                     _loc14_ = this.MenuItemList_mc.entryList.length > 0 ? _loc13_.height * 3 : 0;
                     if(this.DisplayText_tf.textHeight + _loc14_ >= this.DisplayText_tf.height)
                     {
                        this.displayText_startChar += this.DisplayText_tf.length;
                     }
                     else
                     {
                        this.displayText_isDone = true;
                        if(this.hackingHighlightQueued)
                        {
                           this.hackingHighlightQueued = false;
                           this.ShowHackingHighlight(this.queuedHackingHighlightCharIndex1,this.queuedHackingHighlightText1,this.queuedHackingHighlightCharIndex2,this.queuedHackingHighlightText2);
                        }
                     }
                  }
                  else if(this.DisplayText_tf.text.charCodeAt(this.DisplayText_tf.length - 1) == 13 && this.DisplayText_tf.textHeight + _loc13_.height + _loc13_.leading + 1 > this.DisplayText_tf.height)
                  {
                     _loc9_ = true;
                     this.displayText_startChar += this.DisplayText_tf.length;
                  }
                  if(!param1)
                  {
                     _loc10_ = _loc9_;
                     _loc9_ ||= ++_loc8_ >= _loc6_;
                  }
               }
               if(_loc10_)
               {
                  if(this.bShowHackingAttempts)
                  {
                     this.HackingAttempts_tf.visible = true;
                     this.ShowHackingGuesses(true);
                     this.HackingGuess1_mc.gotoAndStop(0);
                     this.HackingGuess2_mc.gotoAndStop(0);
                     this.HackingGuess3_mc.gotoAndStop(0);
                     this.HackingGuess4_mc.gotoAndStop(0);
                     this.HackingGuess5_mc.gotoAndStop(0);
                     this.bShowHackingAttempts = false;
                  }
                  this.bAnimateDisplayText = false;
               }
               _loc2_ = this.ConvertToGlobal(this.DisplayText_tf);
               _loc7_ = param1;
            }
            if(_loc7_)
            {
               if(this.DisplayText_tf.visible && !this.displayText_isDone)
               {
                  this.StopTextTimer();
               }
               else
               {
                  if(this.DisplayText_tf.visible)
                  {
                     _loc15_ = this.displayText_y + this.DisplayText_tf.textHeight + this.displayTextMenuBuffer_y;
                     _loc16_ = _loc15_ - this.MenuItemList_mc.y;
                     this.MenuItemList_mc.border.height -= _loc16_;
                     this.MenuItemList_mc.ScrollDown.y -= _loc16_;
                     this.MenuItemList_mc.y = _loc15_;
                     this.MenuItemList_mc.InvalidateData();
                  }
                  if(this.List_AnimateText(param1,this.BlinkingCursor_mc,_loc6_))
                  {
                     this.ResponsePrompt_tf.visible = true;
                     this.StopTextTimer();
                     stage.focus = this.MenuItemList_mc;
                     if(this.MenuItemList_mc.selectedIndex == -1)
                     {
                        this.MenuItemList_mc.selectedIndex = this.BGSCodeObj.GetStartingListPosition();
                     }
                     _loc2_ = this.ConvertToGlobal(this.ResponseText_tf);
                  }
               }
            }
         }
         if(_loc2_.x != -1)
         {
            this.SetCursorPosition(_loc2_.x,_loc2_.y);
         }
      }
      
      public function UpdateResponseText(param1:Boolean = false) : *
      {
         var _loc2_:int = this.iTickCount;
         this.iTickCount = getTimer();
         var _loc3_:Number = (this.iTickCount - _loc2_) / 1000;
         var _loc4_:uint;
         this.ncharRemainder += (_loc4_ = _loc3_ * this.ucharsPerSec) - _loc4_;
         if(this.ncharRemainder > 1)
         {
            _loc4_ += 1;
            --this.ncharRemainder;
         }
         this.ResponsePrompt_tf.visible = true;
         var _loc5_:Boolean = false;
         if(this.ResponseText_tf.length < this.strResponseText.length || this.ResponseText_tf.text == " " && this.strResponseText.length == 1)
         {
            this.UpdateTextField(this.ResponseText_tf,this.strResponseText,_loc4_,param1);
            this.DisplayHack(this.ResponseText_tf);
         }
         else
         {
            _loc5_ = true;
         }
         var _loc6_:Point = this.ConvertToGlobal(this.ResponseText_tf);
         if(_loc6_.x != -1)
         {
            this.SetCursorPosition(_loc6_.x,_loc6_.y);
         }
         if(_loc5_ || param1)
         {
            this.responseUpdateTimer.stop();
            if(!this.textUpdateTimer.running)
            {
               this.BGSCodeObj.ActivateScrollSound(false);
            }
         }
      }
      
      private function List_AnimateText(param1:Boolean, param2:MovieClip, param3:uint) : Boolean
      {
         var _loc8_:uint = 0;
         var _loc9_:TextField = null;
         var _loc10_:Point = null;
         var _loc4_:Array = this.MenuItemList_mc.entryList;
         var _loc5_:* = _loc4_.length == 0;
         var _loc6_:Boolean = true;
         var _loc7_:uint = 0;
         while(_loc6_ && _loc7_ < _loc4_.length)
         {
            if(_loc4_[_loc7_].isFinished == undefined)
            {
               if(param1)
               {
                  _loc4_[_loc7_].text = _loc4_[_loc7_].fullText.toString();
               }
               else
               {
                  _loc4_[_loc7_].text = _loc4_[_loc7_].fullText.toString().slice(0,_loc4_[_loc7_].text.length + param3);
               }
               if(_loc4_[_loc7_].text.length == _loc4_[_loc7_].fullText.length)
               {
                  _loc4_[_loc7_].isFinished = true;
               }
               _loc8_ = Math.min(_loc7_,this.MenuItemList_mc.itemsShown - 1);
               _loc9_ = this.MenuItemList_mc.GetClipByIndex(_loc8_).getChildByName("textField") as TextField;
               _loc10_ = this.ConvertToGlobal(_loc9_);
               param2.x = _loc10_.x;
               param2.y = _loc10_.y;
               _loc6_ = param1;
            }
            if(_loc4_[_loc7_].isFinished == true && _loc7_ == _loc4_.length - 1)
            {
               _loc5_ = true;
            }
            _loc7_++;
         }
         this.MenuItemList_mc.InvalidateData();
         this.MenuItemList_mc.disableInput_Inspectable = !_loc5_ || _loc4_.length == 0 || !this.MenuItemList_mc.visible;
         return _loc5_;
      }
      
      public function SetCursorPosition(param1:Number, param2:Number) : *
      {
         this.BlinkingCursor_mc.x = param1;
         this.BlinkingCursor_mc.y = param2;
      }
      
      public function ShowHackingHighlight(param1:int, param2:String, param3:int, param4:String) : *
      {
         if(this.displayText_isDone == false)
         {
            this.hackingHighlightQueued = true;
            this.queuedHackingHighlightCharIndex1 = param1;
            this.queuedHackingHighlightText1 = param2;
            this.queuedHackingHighlightCharIndex2 = param3;
            this.queuedHackingHighlightText2 = param4;
            return;
         }
         var _loc5_:Rectangle = new Rectangle();
         var _loc6_:Number = -2;
         var _loc7_:Number = -2;
         var _loc8_:uint = 4;
         if(param1 >= 0)
         {
            _loc5_ = this.DisplayText_tf.getCharBoundaries(param1);
            _loc5_.x += _loc6_;
            _loc5_.y += _loc7_;
            this.HackingHighlight1_mc.visible = true;
            GlobalFunc.SetText(this.HackingHighlight1_mc.HackingHighlightText_tf,param2,false);
            this.HackingHighlight1_mc.HackingHighlightBorder_mc.width = this.HackingHighlight1_mc.HackingHighlightText_tf.getLineMetrics(0).width + _loc8_;
            this.HackingHighlight1_mc.HackingHighlightText_tf.x = _loc5_.x;
            this.HackingHighlight1_mc.HackingHighlightText_tf.y = _loc5_.y;
            this.HackingHighlight1_mc.HackingHighlightBorder_mc.x = _loc5_.x;
            this.HackingHighlight1_mc.HackingHighlightBorder_mc.y = _loc5_.y;
         }
         else
         {
            this.HackingHighlight1_mc.visible = false;
         }
         if(param3 >= 0)
         {
            _loc5_ = this.DisplayText_tf.getCharBoundaries(param3);
            _loc5_.x += _loc6_;
            _loc5_.y += _loc7_;
            this.HackingHighlight2_mc.visible = true;
            GlobalFunc.SetText(this.HackingHighlight2_mc.HackingHighlightText_tf,param4,false);
            this.HackingHighlight2_mc.HackingHighlightBorder_mc.width = this.HackingHighlight2_mc.HackingHighlightText_tf.getLineMetrics(0).width + _loc8_;
            this.HackingHighlight2_mc.HackingHighlightText_tf.x = _loc5_.x;
            this.HackingHighlight2_mc.HackingHighlightText_tf.y = _loc5_.y;
            this.HackingHighlight2_mc.HackingHighlightBorder_mc.x = _loc5_.x;
            this.HackingHighlight2_mc.HackingHighlightBorder_mc.y = _loc5_.y;
         }
         else
         {
            this.HackingHighlight2_mc.visible = false;
         }
      }
      
      public function StartTextTimer() : *
      {
         this.textUpdateTimer.reset();
         this.textUpdateTimer.start();
         this.iTickCount = getTimer();
         this.BGSCodeObj.ActivateScrollSound(true);
      }
      
      public function StopTextTimer() : *
      {
         this.textUpdateTimer.stop();
         this.BGSCodeObj.ActivateScrollSound(false);
      }
      
      public function IsTextAnimating() : Boolean
      {
         return this.textUpdateTimer.running || this.responseUpdateTimer.running;
      }
      
      public function FinishAnimatingText() : *
      {
         this.UpdateText(true);
         this.BGSCodeObj.PlaySound("UITerminalCharEnter");
         this.bAcceptDebounce = this.MenuItemList_mc.visible;
      }
      
      public function set headerText(param1:String) : *
      {
         this.strHeaderText = param1;
         GlobalFunc.SetText(this.HeaderText_tf,"",false);
         this.DisplayHack(this.HeaderText_tf);
      }
      
      public function set welcomeText(param1:String) : *
      {
         this.strWelcomeText = param1;
         GlobalFunc.SetText(this.WelcomeText_tf,"",false);
         this.DisplayHack(this.WelcomeText_tf);
      }
      
      public function set displayText(param1:String) : *
      {
         var _loc2_:* = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         if(this.isHacking)
         {
            this.strDisplayText = param1;
         }
         else
         {
            GlobalFunc.SetText(this.DisplayText_tf,param1,false);
            _loc2_ = "";
            _loc3_ = 0;
            while(_loc3_ < this.DisplayText_tf.numLines)
            {
               _loc4_ = this.DisplayText_tf.getLineText(_loc3_);
               _loc2_ += _loc4_;
               if(_loc4_.charAt(_loc4_.length - 1) != "\r")
               {
                  _loc2_ += "\n";
               }
               _loc3_++;
            }
            this.strDisplayText = _loc2_;
         }
         this.displayText_startChar = 0;
         this.displayText_isDone = false;
         this.DisplayTextNextPage();
      }
      
      public function DisplayTextNextPage() : void
      {
         GlobalFunc.SetText(this.DisplayText_tf,"",false);
         this.DisplayHack(this.DisplayText_tf);
         this.bAnimateDisplayText = true;
         this.StartTextTimer();
      }
      
      public function IsDisplayTextDone() : Boolean
      {
         return !this.DisplayText_tf.visible || this.displayText_isDone;
      }
      
      public function set responseText(param1:String) : *
      {
         this.strResponseText = param1;
         GlobalFunc.SetText(this.ResponseText_tf,"",false);
         this.DisplayHack(this.ResponseText_tf);
         this.responseUpdateTimer.reset();
         this.responseUpdateTimer.start();
         this.iTickCount = getTimer();
         this.BGSCodeObj.ActivateScrollSound(true);
      }
      
      public function SetDisplayMode(param1:Boolean) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         this.isHacking = param1;
         if(param1)
         {
            _loc2_ = this.DisplayText_tf.textHeight + this.DisplayText_tf.getTextFormat().leading;
            _loc3_ = this.DisplayText_tf.getCharBoundaries(0).width;
            this.DisplayText_tf.x = this.HackingHighlight1_mc.x;
            this.DisplayText_tf.y = this.HackingHighlight1_mc.y;
            _loc4_ = _loc3_;
            this.DisplayText_tf.width = this.BGSCodeObj.GetHackingBoardCharWidth() * _loc3_ + _loc4_;
            this.DisplayText_tf.height = this.BGSCodeObj.GetHackingBoardCharHeight() * _loc2_ + 1;
            this.DisplayText_tf.mouseWheelEnabled = false;
            _loc5_ = _loc3_ - 13;
            this.ResponsePrompt_tf.x = this.DisplayText_tf.x + this.DisplayText_tf.width + _loc5_;
            this.ResponsePrompt_tf.y = this.DisplayText_tf.y + this.DisplayText_tf.height - _loc2_ - 1;
            this.ResponseText_tf.x = this.ResponsePrompt_tf.x + _loc3_;
            this.ResponseText_tf.y = this.ResponsePrompt_tf.y;
            this.ResponseText_tf.width = 13 * _loc3_ + 5;
            this.ResponseLog_tf.x = this.ResponsePrompt_tf.x;
            this.ResponseLog_tf.width = this.ResponseText_tf.x + this.ResponseText_tf.width - this.ResponsePrompt_tf.x;
            this.bShowHackingAttempts = true;
         }
         else
         {
            this.DisplayText_tf.x = this.displayText_x;
            this.DisplayText_tf.y = this.displayText_y;
            this.DisplayText_tf.width = this.displayText_width;
            this.DisplayText_tf.height = this.displayText_height;
            this.DisplayText_tf.mouseWheelEnabled = true;
            this.ResponsePrompt_tf.x = this.responsePrompt_x;
            this.ResponsePrompt_tf.y = this.responsePrompt_y;
            this.ResponseText_tf.x = this.responseText_x;
            this.ResponseText_tf.y = this.responseText_y;
            this.ResponseText_tf.width = this.responseText_width;
            this.ResponseLog_tf.visible = false;
            this.HackingAttempts_tf.visible = false;
            this.ShowHackingGuesses(false);
         }
      }
      
      public function PushResponseLog(param1:String, param2:Boolean) : void
      {
         var _loc6_:String = null;
         var _loc7_:uint = 0;
         if(param2)
         {
            this.PushResponseLog(this.strResponseText,false);
         }
         param1 = ">" + param1;
         if(!this.ResponseLog_tf.visible)
         {
            GlobalFunc.SetText(this.ResponseLog_tf,"",false);
            this.ResponseLog_tf.visible = true;
         }
         var _loc3_:uint = this.BGSCodeObj.GetHackingBoardCharHeight() - 1;
         var _loc4_:uint = this.ResponseLog_tf.text.length == 1 ? 0 : uint(this.ResponseLog_tf.numLines);
         if(_loc4_ >= _loc3_)
         {
            _loc6_ = new String();
            _loc7_ = uint(_loc4_ - _loc3_ + 1);
            while(_loc7_ < _loc4_)
            {
               _loc6_ += this.ResponseLog_tf.getLineText(_loc7_);
               _loc7_++;
            }
            this.ResponseLog_tf.text = _loc6_;
         }
         if(_loc4_ == 0)
         {
            this.ResponseLog_tf.text = param1;
         }
         else
         {
            this.ResponseLog_tf.text = this.ResponseLog_tf.text + "\n" + param1;
         }
         var _loc5_:Number = this.DisplayText_tf.getLineMetrics(0).height + this.DisplayText_tf.getTextFormat().leading + 0.5;
         this.ResponseLog_tf.height = _loc5_ * this.ResponseLog_tf.numLines + 1;
         this.ResponseLog_tf.y = this.ResponseText_tf.y - this.ResponseLog_tf.height;
      }
      
      private function updateAttempts() : void
      {
         var displayTextArr:Array;
         var column1Text:String;
         var column2Text:String;
         var hackingText:String;
         var words:Array;
         var solutions:Array;
         var isMatching:Boolean;
         var j:int;
         var k:int;
         var matching:int;
         var responses:Array;
         var line:String;
         var prevLine:String;
         var prevLine2:String;
         var i:int;
         var word:String;
         var attempt:Object;
         var attemptWord:String;
         var misMatches:Array;
         try
         {
            if(!this.isHacking || this.IsTextAnimating())
            {
               return;
            }
            if(this.isUpdating)
            {
               return;
            }
            this.isUpdating = true;
            this.WelcomeText_tf.text = "";
            this.HeaderText_tf.text = "";
            displayTextArr = this.strDisplayText.split(/0x\S{4}\s{1}/);
            column1Text = "";
            column2Text = "";
            i = 0;
            while(i < displayTextArr.length)
            {
               if(i % 2)
               {
                  column1Text += displayTextArr[i].replace(/\s+/g,"");
               }
               else
               {
                  column2Text += displayTextArr[i].replace(/\s+/g,"");
               }
               i++;
            }
            hackingText = column1Text + column2Text;
            words = hackingText.match(/[A-Z]{3,}/g);
            words = words.filter(function(w:String):Boolean
            {
               return attemptWords[w] == null;
            });
            responses = this.ResponseLog_tf.text.replace("\r","").replace("\n","").split(">");
            if(responses.length < 2)
            {
               if(words.length > 0)
               {
                  this.HeaderText_tf.text = "GUESS: " + words[0];
                  nextGuess(words[0],hackingText);
               }
               return;
            }
            line = "";
            prevLine = "";
            prevLine2 = "";
            i = 0;
            while(i < responses.length)
            {
               prevLine2 = prevLine;
               prevLine = line;
               line = responses[i].replace(/\s+/g,"").replace(/ /g,"");
               if(i > 1 && /.*\=[0-9]+/.test(line) && prevLine2.length > 0 && !Boolean(attemptWords[prevLine2]))
               {
                  attempts.push({
                     "word":prevLine2,
                     "matches":Number(line.split("=")[1])
                  });
                  attemptWords[prevLine2] = true;
               }
               i++;
            }
            if(attempts.length == 0)
            {
               if(words.length > 0)
               {
                  this.HeaderText_tf.text = "GUESS: " + words[0];
                  nextGuess(words[0],hackingText);
               }
               return;
            }
            if(false)
            {
               for each(att in attempts)
               {
                  this.HeaderText_tf.text = this.HeaderText_tf.text + att.word + ":" + att.matches + " ";
               }
            }
            solutions = [];
            misMatches = [];
            isMatching = true;
            i = 0;
            while(i < words.length)
            {
               word = words[i];
               isMatching = true;
               j = 0;
               while(j < attempts.length)
               {
                  attempt = attempts[j];
                  attemptWord = attempt.word;
                  matching = 0;
                  k = 0;
                  while(k < word.length)
                  {
                     if(word.charCodeAt(k) == attemptWord.charCodeAt(k))
                     {
                        matching++;
                     }
                     k++;
                  }
                  if(matching != attempt.matches)
                  {
                     isMatching = false;
                     j = int(attempts.length);
                  }
                  j++;
               }
               if(isMatching)
               {
                  solutions.push(word);
               }
               else
               {
                  misMatches.push(word);
               }
               i++;
            }
            if(solutions.length > 0)
            {
               if(solutions.length == 1)
               {
                  this.WelcomeText_tf.text = "PASSWORD FOUND: " + solutions[0];
                  this.HeaderText_tf.text = "UNLOCK: " + solutions[0];
               }
               else
               {
                  this.WelcomeText_tf.text = "MATCHES: " + solutions.join(" ");
                  this.HeaderText_tf.text = "ATTEMPT: " + solutions[0];
               }
               nextGuess(solutions[0],hackingText);
            }
         }
         catch(e:*)
         {
            this.WelcomeText_tf.text = "error " + e;
         }
      }
      
      private function nextGuess(word:String, hackingText:String) : void
      {
         var colNumber:int;
         var rowIndex:int;
         var colIndex:int;
         var d_charIndex:int;
         var wordIndex:int = int(hackingText.indexOf(word));
         if(wordIndex != -1)
         {
            colNumber = int(wordIndex > 191);
            rowIndex = Math.floor(wordIndex / 12) % 16;
            colIndex = wordIndex % 12;
            d_charIndex = 40 * rowIndex + 7 + colIndex;
            if(colNumber == 1)
            {
               d_charIndex += 20;
            }
            this.BGSCodeObj.SelectHackingWord(d_charIndex,rowIndex);
            if(false)
            {
               this.HackingAttempts_tf.text = d_charIndex + "," + rowIndex;
            }
            setTimeout(function():void
            {
               isUpdating = false;
               BGSCodeObj.ValidateHackingWord();
            },100);
         }
      }
      
      public function ShowHackingGuesses(param1:Boolean) : void
      {
         var _loc2_:uint = 0;
         if(param1)
         {
            _loc2_ = uint(this.BGSCodeObj.GetNumGuesses());
            this.HackingGuess1_mc.visible = _loc2_ >= 1;
            this.HackingGuess2_mc.visible = _loc2_ >= 2;
            this.HackingGuess3_mc.visible = _loc2_ >= 3;
            this.HackingGuess4_mc.visible = _loc2_ >= 4;
            this.HackingGuess5_mc.visible = _loc2_ >= 5;
         }
         else
         {
            this.HackingGuess1_mc.visible = false;
            this.HackingGuess2_mc.visible = false;
            this.HackingGuess3_mc.visible = false;
            this.HackingGuess4_mc.visible = false;
            this.HackingGuess5_mc.visible = false;
         }
      }
      
      public function RemoveGuessBlock() : void
      {
         if(this.HackingGuess5_mc.visible)
         {
            this.HackingGuess5_mc.visible = false;
         }
         else if(this.HackingGuess4_mc.visible)
         {
            this.HackingGuess4_mc.visible = false;
         }
         else if(this.HackingGuess3_mc.visible)
         {
            this.HackingGuess3_mc.visible = false;
         }
         else if(this.HackingGuess2_mc.visible)
         {
            this.HackingGuess2_mc.visible = false;
         }
         else if(this.HackingGuess1_mc.visible)
         {
            this.HackingGuess1_mc.visible = false;
         }
      }
      
      public function ProcessUserEvent(param1:String, param2:Boolean) : Boolean
      {
         var _loc3_:Boolean = false;
         if(!param2 && this.IsTextAnimating() && (param1 == "Accept" || param1 == "Activate"))
         {
            this.FinishAnimatingText();
            _loc3_ = true;
         }
         return _loc3_;
      }
      
      public function LoadDisplayImage(param1:String) : void
      {
         if(this.DisplayImage_mc.numChildren > 0)
         {
            this.DisplayImage_mc.removeChildren();
         }
         this.DisplayImageLoader = new Loader();
         this.DisplayImageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onDisplayImageLoadComplete);
         this.DisplayImageLoader.load(new URLRequest("img://" + param1));
      }
      
      private function onDisplayImageLoadComplete(param1:Event) : *
      {
         this.DisplayImage_mc.addChild(param1.currentTarget.content);
         this.DisplayImageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onDisplayImageLoadComplete);
         this.DisplayImageLoader = null;
      }
      
      protected function onItemPress() : *
      {
         if(!this.bAcceptDebounce)
         {
            this.BGSCodeObj.OnMenuItemSelect();
         }
         else
         {
            this.bAcceptDebounce = false;
         }
      }
      
      public function onMouseClick(param1:MouseEvent) : void
      {
         if(this.IsTextAnimating())
         {
            this.FinishAnimatingText();
         }
      }
   }
}

