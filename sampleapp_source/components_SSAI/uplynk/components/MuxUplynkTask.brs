function getAnalytics() as Object
  mux = {}
  mux.append(muxAnalytics())
  mux._hasSeenAdStartEvent = false
  mux["_rafEventHandler"] = mux["rafEventHandler"]
  mux["rafEventHandler"] = uplynkRAFHandler
  return mux
end function

' Uplynk doesnt provide a Start event so we need to polyfill for that
function uplynkRAFHandler(rafEvent)
  data = rafEvent.getData()
  eventType = data.eventType
  if eventType = "Start" then m._hasSeenAdStartEvent = true
  if eventType = "Complete" OR eventType = "PodComplete" then m._hasSeenAdStartEvent = false
  if eventType = "Impression" AND m._hasSeenAdStartEvent <> true
    polyfillEvent = {}
    polyfillEvent.append(data)
    polyfillEvent.eventType = "Start"
    m._hasSeenAdStartEvent = true
    m._rafEventHandler(polyfillEvent)
  end if
  m._rafEventHandler(rafEvent)
end function