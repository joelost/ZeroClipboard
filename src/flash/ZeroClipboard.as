﻿package {

  import flash.display.Stage;
  import flash.display.Sprite;
  import flash.display.LoaderInfo;
  import flash.events.*;
  import flash.external.ExternalInterface;
  import flash.utils.*;
  import flash.system.System;
  import flash.system.Capabilities;

  public class ZeroClipboard extends Sprite {

    private var button:Sprite;
    private var clipText:String = '';

    public function ZeroClipboard() {
      // constructor, setup event listeners and external interfaces
      stage.align = "TL";
      stage.scaleMode = "noScale";
      flash.system.Security.allowDomain("*");

      // import flashvars
      var flashvars:Object = LoaderInfo( this.root.loaderInfo ).parameters;
      // invisible button covers entire stage
      button = new Sprite();
      button.buttonMode = true;
      button.useHandCursor = false;
      button.graphics.beginFill(0xCCFF00);
      button.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
      button.alpha = 0.0;
      addChild(button);
      button.addEventListener(MouseEvent.CLICK, function(event:MouseEvent): void {
        // user click copies text to clipboard
        // as of flash player 10, this MUST happen from an in-movie flash click event
        System.setClipboard( clipText );
        ExternalInterface.call( 'ZeroClipboard.dispatch', 'complete',  metaData(event, {
          text: clipText
        }));
      });

      button.addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent): void {
        ExternalInterface.call( 'ZeroClipboard.dispatch', 'mouseOver', metaData(event) );
      } );
      button.addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent): void {
        ExternalInterface.call( 'ZeroClipboard.dispatch', 'mouseOut', metaData(event) );
      } );
      button.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent): void {
        ExternalInterface.call( 'ZeroClipboard.dispatch', 'mouseDown', metaData(event) );
      } );
      button.addEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent): void {
        ExternalInterface.call( 'ZeroClipboard.dispatch', 'mouseUp', metaData(event) );
      } );

      // external functions
      ExternalInterface.addCallback("setHandCursor", setHandCursor);
      ExternalInterface.addCallback("setText", setText);
      ExternalInterface.addCallback("setSize", setSize);

      // signal to the browser that we are ready
      ExternalInterface.call( 'ZeroClipboard.dispatch', 'load', metaData() );
    }

    private function metaData(event:MouseEvent = void, extra:Object = void):Object {
      var normalOptions:Object = {
        flashVersion : Capabilities.version
      }

      if (event) {
        normalOptions.altKey = event.altKey;
        normalOptions.ctrlKey = event.ctrlKey;
        normalOptions.shiftKey = event.shiftKey;
      }

      for(var i:String in extra) {
        normalOptions[i] = extra[i];
      }

      return normalOptions;
    }

    public function setText(newText:String): void {
      // set the maximum number of files allowed
      clipText = newText;
    }

    public function setHandCursor(enabled:Boolean): void {
      // control whether the hand cursor is shown on rollover (true)
      // or the default arrow cursor (false)
      button.useHandCursor = enabled;
    }

    public function setSize(width:Number, height:Number): void {
      button.width = width;
      button.height = height;
    }
  }
}