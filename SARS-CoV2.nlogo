turtles-own
[
  state               ;; 0 - susceptible, 1 - asymptomatically infected, 2 - symptomatically infected, 3 - cured and immune, 4 - dead (and immune)
  quarantine?         ;; if true this person is in quarantine and thus has no links
  incubation          ;; Time until the person realizes to be infected
  infection-length    ;; How long the person has been infected
  recovery            ;; Time (in ticks) it takes before the person has a chance to recover from the infection
  fatality
  traced?
]

undirected-link-breed [blue-links bluelink]
undirected-link-breed [orange-links orangelink]
undirected-link-breed [grey-links greylink]

to setup
  clear-all
  
  create-turtles population 
  [ 
    setxy random-xcor random-ycor 
    set state 0
    set quarantine? false
    set traced? false
    
    set shape "person"
    set color white
    
    set incubation incubation-time
    set recovery recovery-time
  ]
  setup-community1
  setup-community2
  setup-community3
  
  infect
  reset-ticks
end


to go
  
  community1
  community2
  community3
  
  infect
  spread
  update-state
  trace-back
  quarantine
  recolor
  tick
end




to infect
  repeat new-infections
  [
    ask one-of turtles with [state = 0] 
    [
      set state 1
      set infection-length 0
      set fatality mortality-rate
    ]
  ]  
end

to quarantine
  ask turtles with [quarantine?]
  [
    set label "q"
    ask my-links [die]
  ]
end

to update-state
  ask turtles
  [
    if state = 1 [if infection-length >= incubation [set state 2]]
    if state = 2 [if infection-length >= recovery [ifelse random-float 100 < fatality [set state 4][set state 3]]]
    
    if quarantine-symptomatic? [if state = 2 [set quarantine? true]]
    if state != 0 [set infection-length infection-length + 1]
  ]
end

to recolor
  ask turtles
  [
    if state = 1 [set color yellow]
    if state = 2 [set color red]
    if state = 3 [set color green]
    if state = 4 [set color 2]
  ]
end


to setup-community1
  if comm1-lockdown? = false
  [
    ask turtles [setxy random-xcor random-ycor]
    ask turtles
    [
      ask other turtles in-radius community1-radius
      [
        create-blue-links-with other turtles in-radius community1-radius [set color blue]
      ]
    ]
  ]
end

to setup-community2
  if comm2-lockdown? = false
  [
    ask turtles [setxy random-xcor random-ycor]
    ask turtles
    [
      ask other turtles in-radius community2-radius
      [
        create-orange-links-with other turtles in-radius community2-radius [set color orange]
      ]
    ]
  ]
end

to setup-community3
  if comm3-lockdown? = false
  [
    ask turtles [setxy random-xcor random-ycor]
    ask turtles
    [
      ask other turtles in-radius community3-radius
      [
        create-grey-links-with other turtles in-radius community3-radius [set color grey]
      ]
    ]
  ]
end




to community1
  ifelse comm1-lockdown? = true [ask blue-links [die]]
  [
    ifelse comm1-dynamic? 
    [
      ask blue-links [die]
      ask turtles [setxy random-xcor random-ycor]
      ask turtles
      [
        ask other turtles in-radius community1-radius
        [
          create-blue-links-with other turtles in-radius community1-radius [set color blue]
        ]
      ]
    ]
    [;else
      ; can introduce some small local movements here
    ]
  ]
end

to community2
  ifelse comm2-lockdown? = true [ask orange-links [die]]
  [
    ifelse comm2-dynamic? 
    [
      ask orange-links [die]
      ask turtles [setxy random-xcor random-ycor]
      ask turtles
      [
        ask other turtles in-radius community2-radius
        [
          create-orange-links-with other turtles in-radius community2-radius [set color orange]
        ]
      ]
    ]
    [;else
      ; can introduce some small local movements here
    ]
  ]
end

to community3
  ifelse comm3-lockdown? = true [ask grey-links [die]]
  [
    ifelse comm3-dynamic? 
    [
      ask grey-links [die]
      ask turtles [setxy random-xcor random-ycor]
      ask turtles
      [
        ask other turtles in-radius community3-radius
        [
          create-grey-links-with other turtles in-radius community3-radius [set color grey]
        ]
      ]
    ]
    [;else
      ; can introduce some small local movements here
    ]
  ]
end





to spread
  ask turtles with [state = 1 or state = 2]
  [
    ask bluelink-neighbors
    [
      if random-float 100 < comm1-secondaryAttackRate
      [
        if state = 0
        [
          set state 1
          set infection-length 0
          set fatality mortality-rate
        ]
      ]
    ]
    
    ask orangelink-neighbors
    [
      if random-float 100 < comm2-secondaryAttackRate
      [
        if state = 0
        [
          set state 1
          set infection-length 0
          set fatality mortality-rate
        ]
      ]
    ]
    
    ask greylink-neighbors
    [
      if random-float 100 < comm3-secondaryAttackRate
      [
        if state = 0
        [
          set state 1
          set infection-length 0
          set fatality mortality-rate
        ]
      ]
    ]
    
  ]
end


to trace-back
  ask turtles with [state = 2]
  [
    set traced? true
  ]
  
  if comm1-dynamic? = false and quarantine-traced-back-to-symptomatic?
  [
    while [any? turtles with [traced? = false and any? bluelink-neighbors with [traced? = true]]]
    [
      ask turtles
      [
        if any? bluelink-neighbors with [traced? = true]
        [
          set traced? true
          set quarantine? true
          set label "q"
        ]
      ]
    ]
  ]
  
  if comm2-dynamic? = false and quarantine-traced-back-to-symptomatic?
  [
    while [any? turtles with [traced? = false and any? orangelink-neighbors with [traced? = true]]]
    [
      ask turtles
      [
        if any? orangelink-neighbors with [traced? = true]
        [
          set traced? true
          set quarantine? true
          set label "q"
        ]
      ]
    ]
  ]
  
  if comm3-dynamic? = false and quarantine-traced-back-to-symptomatic?
  [
    while [any? turtles with [traced? = false and any? greylink-neighbors with [traced? = true]]]
    [
      ask turtles
      [
        if any? greylink-neighbors with [traced? = true]
        [
          set traced? true
          set quarantine? true
          set label "q"
        ]
      ]
    ]
  ]
  
  ask turtles with [quarantine?]
  [
    ask my-links [die]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
499
78
1320
920
16
16
24.6
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

SLIDER
8
51
180
84
population
population
2
2000
2000
1
1
NIL
HORIZONTAL

BUTTON
8
10
72
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
14
446
186
479
community1-radius
community1-radius
0.1
3
0.6
.1
1
NIL
HORIZONTAL

SLIDER
15
653
187
686
community2-radius
community2-radius
0.1
3
0.7
.1
1
NIL
HORIZONTAL

SWITCH
15
485
164
518
comm1-dynamic?
comm1-dynamic?
1
1
-1000

SWITCH
15
691
164
724
comm2-dynamic?
comm2-dynamic?
1
1
-1000

SWITCH
14
407
169
440
comm1-lockdown?
comm1-lockdown?
1
1
-1000

BUTTON
109
806
227
882
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SWITCH
15
615
170
648
comm2-lockdown?
comm2-lockdown?
1
1
-1000

SWITCH
8
318
289
351
quarantine-traced-back-to-symptomatic?
quarantine-traced-back-to-symptomatic?
0
1
-1000

SLIDER
9
241
181
274
new-infections
new-infections
0
100
1
1
1
NIL
HORIZONTAL

SLIDER
7
90
179
123
incubation-time
incubation-time
0
30
6
1
1
NIL
HORIZONTAL

SLIDER
8
129
180
162
recovery-time
recovery-time
0
50
16
1
1
NIL
HORIZONTAL

SLIDER
8
169
180
202
mortality-rate
mortality-rate
0
100
2
1
1
%
HORIZONTAL

SWITCH
9
280
204
313
quarantine-symptomatic?
quarantine-symptomatic?
0
1
-1000

PLOT
1340
79
1863
348
progression of the states
time
occurance
0.0
20.0
0.0
100.0
true
true
"" ""
PENS
"susceptible" 1.0 0 -7500403 true "" "plot count turtles with [state = 0]"
"asymptomatic" 1.0 0 -1184463 true "" "plot count turtles with [state = 1]"
"symptomatic" 1.0 0 -2674135 true "" "plot count turtles with [state = 2]"
"cured" 1.0 0 -10899396 true "" "plot count turtles with [state = 3]"
"dead" 1.0 0 -16777216 true "" "plot count turtles with [state = 4]"

SLIDER
15
536
243
569
comm1-secondaryAttackRate
comm1-secondaryAttackRate
0
100
50
1
1
%
HORIZONTAL

TEXTBOX
190
52
340
70
number of agents in the model
11
0.0
1

TEXTBOX
190
90
364
132
infected time without symptoms, can transmit the disease
11
0.0
1

TEXTBOX
190
131
391
173
time until recovery. Recovered agents become either immune or die
11
0.0
1

TEXTBOX
190
170
340
198
share of infected agents that die
11
0.0
1

TEXTBOX
191
242
476
298
number of susceptible agents that randomly get infected per iteration without a link to an already infected agent
11
0.0
1

TEXTBOX
210
281
360
309
deletes links from an agent with symptoms
11
0.0
1

TEXTBOX
303
315
453
371
deletes all links of agents that can be connected to an agent with symptoms (works only for non-dynamic networks)
11
0.0
1

TEXTBOX
274
813
424
873
click on \"go\" to execute next iteration
16
0.0
1

TEXTBOX
16
381
203
421
Community 1 - blue links
16
0.0
1

TEXTBOX
178
408
328
426
enable community?
11
0.0
1

TEXTBOX
199
447
402
489
radius of agents that form links \ninfluences number of links per agent
11
0.0
1

TEXTBOX
172
482
474
566
Static communities stay linked to the same agents (like families). Dynamic communities change links in every iteration (like bus passengers)
11
0.0
1

TEXTBOX
252
539
470
581
chance of transmitting the disease per iteration for agents that are linked
11
0.0
1

TEXTBOX
17
594
227
634
Community 2 - orange links
16
0.0
1

SLIDER
15
727
243
760
comm2-secondaryAttackRate
comm2-secondaryAttackRate
0
100
9
1
1
%
HORIZONTAL

TEXTBOX
258
595
448
635
Community 3 - grey links
16
0.0
1

SWITCH
256
615
411
648
comm3-lockdown?
comm3-lockdown?
1
1
-1000

SWITCH
257
690
406
723
comm3-dynamic?
comm3-dynamic?
0
1
-1000

SLIDER
256
652
428
685
community3-radius
community3-radius
0
3
0.4
.1
1
NIL
HORIZONTAL

SLIDER
257
728
485
761
comm3-secondaryAttackRate
comm3-secondaryAttackRate
0
100
2
1
1
%
HORIZONTAL

MONITOR
1489
359
1551
404
susceptible
count turtles with [state = 0]
1
1
11

MONITOR
1558
360
1647
405
asymptomatic
count turtles with [state = 1]
1
1
11

MONITOR
1653
361
1735
406
symptomatic
count turtles with [state = 2]
1
1
11

MONITOR
1740
361
1797
406
cured
count turtles with [state = 3]
1
1
11

MONITOR
1802
362
1859
407
dead
count turtles with [state = 4]
1
1
11

TEXTBOX
1345
374
1495
394
total numbers:
16
0.0
1

TEXTBOX
1346
458
1496
478
in quarantine:
16
0.0
1

MONITOR
1488
454
1553
499
susceptible
count turtles with [quarantine? and state = 0]
1
1
11

MONITOR
1558
454
1647
499
asymptomatic
count turtles with [quarantine? and state = 1]
1
1
11

MONITOR
1652
454
1734
499
symptomatic
count turtles with [quarantine? and state = 2]
1
1
11

MONITOR
1799
454
1856
499
total
count turtles with [quarantine?]
1
1
11

TEXTBOX
500
22
1279
207
Agent - based - model for simulating pandemics
30
0.0
1

TEXTBOX
1159
38
1309
56
by Achim Gerstenberg
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
