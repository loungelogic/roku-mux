' ********** Copyright 2017 Roku,Inc.  All Rights Reserved. **********
function init()
  m.top.backgroundURI = ""
  m.top.backgroundColor = "0x111111FF"
  m.video = m.top.findNode("mainVideo")
  m.video.notificationInterval = 1
  setupContent()
  setupMux()
  m.list = m.top.findNode("MenuList")
  m.list.setFocus(true)
  m.list.observeField("itemSelected", "onItemSelected")
  m.plyrTask = invalid
end function

sub setupMux()
  muxConfig = {
    property_key: "<YOUR PROPERTY KEY>",
    player_name: "SSAI Uplynk Player"
  }
  m.mux = m.top.FindNode("mux")
  m.mux.setField("video", m.video)
  m.mux.setField("config", muxConfig)
  m.mux.setField("exitType", "soft")
  m.mux.control = "RUN"
  m.mux.observeField("state", "muxTaskStateChangeHandler")
end sub

sub muxTaskStateChangeHandler(event as object)
  state = event.getData()
  if state = "done" or state = "stop"
    m.mux.control = "RUN"
  end if
end sub

function setupContent()
  contentList = m.top.findNode("contentList")
  items = parsejson(readAsciiFile("pkg:/feed/uplynk_contents.json"))
  if invalid <> items and invalid <> items["contents"]
    for each itemInfo in items["contents"]
      itm = createObject("roSGNode", "TestContent")
      itm.setFields(itemInfo)
      contentList.appendChild(itm)
    end for
  end if
end function

function onItemSelected(msg as object)
  if invalid = m.plyrTask
    m.plyrTask = createObject("roSGNode", "PlayerTask")
    m.plyrTask.observeField("state", "onTaskStateUpdated")
  end if
  if invalid = m.prplyTask
    m.prplyTask = createObject("roSGNode", "PreplayTask")
    m.prplyTask.observeField("state", "onTaskStateUpdated")
  end if
  itemIdx = msg.getData()
  cont = m.list.content.getChild(itemIdx)
  ' ~~~ Let adapter know test data
  testConfig = { url: cont.url, title: cont.title, type: "vod" }
  if cont.live then testConfig["type"] = "live"
  ' ~~~ Optional, with or without calling stich
  if not cont.useStitched then testConfig["useStitched"] = false

  tsk = m.plyrTask
  if 0 < cont.title.inStr("preplay")
    tsk = m.prplyTask
  end if
  tsk.testConfig = testConfig
  tsk.video = m.video
  m.list.visible = false
  m.video.setFocus(true)
  m.mux.setField("view", "start")
  tsk.control = "run"
end function

function onTaskStateUpdated(msg as object)
  if msg.getData() = "stop" OR msg.getData() = "done"
    backToMainMenu()
  end if
end function

function backToMainMenu() as void
  m.mux.setField("view", "end")
  m.mux.exit = true
  m.video.visible = false
  m.list.visible = true
  m.list.setFocus(true)
  m.list.observeField("itemSelected", "onItemSelected")
end function

function onKeyEvent(key as string, press as boolean) as boolean
  if press then
    if key = "back" then
      if m.plyrTask.adPlaying = false
        print "<> <> <> Main.onKeyEvent() ad not playing"
        backToMainMenu()
        m.video.control = "stop"
        m.plyrTask.control = "stop"
      else
        print "<> <> <> Main.onKeyEvent() ad Playing"
      end if
      return true
    end if
  end if
  return false
end function
