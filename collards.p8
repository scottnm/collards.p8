pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- run the main game
#include main.lua
__gfx__
00000000044444444454440000000000000000000000000077777777000000000000000077777777000000000000000000000000000000000000000000000000
00000000504444445444004400000044000000440000004477777777000000000000000077777777000000000000000000000000000000000000000000000000
00000000550444445400444500004445000044450000444577777777000000000000000077777777000000000000000000000000000000000000000000000000
00000000555044445044454400444544004445440044454477777777000000000000000077777777000000000000000000000000000000000000000000000000
00000000555504445555444404454444044544440045444477777777000000000000000077777777000000000000000000000000000000000000000000000000
00000000555550445505454544004545550545455500454577777777000000000000000077777777000000000000000000000000000000000000000000000000
00000000555555045505504444440044550550445505004477777777000000000000000077777777000000000000000000000000000000000000000000000000
00000000555555505505505045454400555550555555500077777777000000000000000077777777000000000000000000000000000000000000000000000000
00000000000000005505505500000000004444444444440000000000000000000000000077777777000000000000000000000000000000000000000000000000
00000000000000005505505500000000440044444444004400000000000000000000000077777777000000000000000000000000000000000000000000000000
00000000000000005505505500000000544400444400444500000000000000000000000077777777000000000000000000000000000000000000000000000000
00000000000000005505505500000000445444000044454400000000000000000000000077777777000000000000000000000000000000000000000000000000
00000000000000005505505500000000444454400445444400000000000000000000000077777777000000000000000000000000000000000000000000000000
00000000000000005505505500000000545400444400454500000000000000000000000077777777000000000000000000000000000000000000000000000000
00000000000000005505505500000000440044444444004400000000000000000000000077777777000000000000000000000000000000000000000000000000
00000000000000005505505500000000004454544545440000000000000000000000000077777777000000000000000000000000000000000000000000000000
00000000000000000000000044544400004444440000000000000000000000000000000077777777000000000000000000000000000000000000000000000000
00000000000000000000000044440044440044440000000000000044440000000000000077777777000000000000000000000000000000000000000000000000
00000000000000000000000054004445544400440000000000004445544400000000000077777777000000000000000000000000000000000000000000000000
00000000000000000000000050444544445444000000000000444544445444000000000077777777000000000000000000000000000000000000000000000000
00000000000000000000000055554444444454400000000404454444444454440000000077777777000000000000000000000000000000000000000000000000
00000000000000000000000055054545545400440000044444004545545400444400000077777777000000000000000000000000000000000000000000000000
00000000000000000000000055055044440044440004444444440044440044444444000077777777000000000000000000000000000000000000000000000000
00000000000000000000000055055050004454540444545445454400004454544545440077777777000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000004444000000000000000000000000000000000000000000004444000000000000000000000000000000000000000000004444000000
00000000000000000000444554440000000000000000000000000000000000000000444554440000000000000000000000000000000000000000444554440000
00000000000000000044454444544400000000000000000000000000000000000044454444544400000000000000000000000000000000000044454444544400
00000000000000040445444444445444000000000000000000000000000000040445444444445444000000000000000000000000000000040445444444445444
00000000000004444400454554540044440000000000000000000000000004444400454554540044440000000000000000000000000004444400454554540044
00000000000444444444004444004444444400000000000000000000000444444444004444004444444400000000000000000000000444444444004444004444
00000000044454544545440000445454454544000000000000000000044454544545440000445454454544000000000000000000044454544545440000445454
00000000004444444444440000444444444444000000000000000000004444444444440000444444444444000000000000000000004444444444440000444444
00000044440044444444004444004444444400444400000000000044440044444444004444004444444400444400000000000044440044444444004444004444
00004445544400444400444554440044440044455444000000004445544400444400444554440044440044455444000000004445544400444400444554440044
00444544445444000044454444544400004445444454440000444544445444000044454444544400004445444454440000444544445444000044454444544400
04454444444454400445444444445440044544444444544004454444444454400445444444445440044544444444544004454444444454400445444444445440
05004545545400444400454554540044440045455454005005004545545400444400454554540044440045455454001005004545545400444400454554540044
05050044440044444444004444004444444400444400505005050044440044444444004444004444444400444400101005050044440044444444004444004444
05055050004454544545440000445454454544000505505005055050004454544545440000445454454544000101101005055050004454544545440000445454
05055055004444444444440000444444444444005505505005055055004444444444440000444444444444001101101005055055004444444444440000444444
05055055050044444444004444004444444400505505505005055055050044444444004444004444444400101101101005055055050044444444004444004444
05055055050500444400444554440044440050505505505005055055050500444400444554440044440010101101101005055055050500444400444554440044
05055055550550000044454444544400000550555505505005055055550550000044454444544400000110111101101005055055550550000044454444544400
05055055050550500445444444445440050550505505505005055055050550500445444444445440010110101101101005055055050550500445444444445440
05555055050550550500454554540050550550505505555005555055050550550500454554540010110110101101111005555055050550550500454554540010
05055055050550550550004444000550550550505505505005055055050550550550004444000110110110101101101005055055050550550550004444000110
05055055050550550550550000550550550550505505505005055055050550550550550000110110110110101101101005055055050550550550550000110110
05055055050555550550550550550550555550505505505005055055050555550550550510110110111110101101101005055055050555550550550510110110
05055055050550550550550550550550550550505505505005055055050550550550550510110110110110101101101005055055050550550550550510110110
05055555050550550550550550550550550550505555505005055555050550550550550510110110110110101111101005055555050550550550550510110110
05055055050550550550550550550550550550505505505005055055050550550550550510110110110110101101101005055055050550550550550510110110
05055055050550550550550050550550550550505505505005055055050550550550550010110110110110101101101005055055050550550550550010110110
05055055050550550550550050550550550550505505505005055055050550550550550010110110110110101101101005055055050550550550550010110110
05055055550550550550555055550550550550555505505005055055550550550550555011110110110110111101101005055055550550550550555011110110
05055055050550550550555055550550550550505505505005055055050550550550555011110110110110101101101005055055050550550550555011110110
00000000000000000000000000000000000000000000000400444444444454444445444444444400400000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000044444004444444555444455544444440044444000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000004445544440044444455444455444444004444554440000000000000000000000000000000000000000000
00000000000000000000000000000000000000000444445544444400444444444444444400444444554444400000000000000000000000000000000000000000
00000000000000000000000000000000000000055444444444444445504444444444440554444444444444455000000000000000000000000000000000000004
00000000000000000000000000000000000004555444444444444445540044444444004554444444444444455540000000000000000000000000000000000444
00000000000000000000000000000000000444444444444444554444444400444400444444445544444444444444400000000000000000000000000000044444
00000000000000000000000000000000004444444444444444555444444444000044444444455544444444444444440000000000000000000000000004445454
00000000000000000000000000000004004444444444544444454444444444000044444444445444444544444444440040000000000000000000000000000000
00000000000000000000000000000444440044444445554444555444444400444400444444455544445554444444004444400000000000000000000000000000
00000000000000000000000000044455444400444444554444554444440044444444004444445544445544444400444455444000000000000000000000000000
00000000000000000000000004444455444444004444444444444444004444444444440044444444444444440044444455444440000000000000000000000000
00000000000000000000000554444444444444455044444444444405544444444444444550444444444444055444444444444445500000000000000000000000
00000000000000000000045554444444444444455400444444440045544444444444444554004444444400455444444444444445554000000000000000000000
00000000000000000004444444444444445544444444004444004444444455444455444444440044440044444444554444444444444440000000000000000000
00000000000000000044444444444444445554444444440000444444444555444455544444444400004444444445554444444444444444000000000000000000
00000000000000040044444444445444444544444444440000444444444454444445444444444400004444444444544444454444444444004000000000000000
00000000000004444400444444455544445554444444004444004444444555444455544444440044440044444445554444555444444400444440000000000000
00000000055444444444004444445544445544444400444444440044444455444455444444004444444400444444554444554444440044444444455000000000
00000000555444444444440044444444444444440044444444444400444444444444444400444444444444004444444444444444004444444444455500000000
00000044555444444444444550444444444444055444444444444445504444444444440554444444444444455044444444444405544444444444455544000000
00004444444444544444444554004444444400455444444444444445540044444444004554444444444444455400444444440045544444444544444444440000
00444444444444554455444444440044440044444444554444554444444400444400444444445544445544444444004444004444444455445544444444444400
04444444544444554455544444444400004444444445554444555444444444000044444444455544445554444444440000444444444555445544444544444440
04444445554444444555544444444400004444444445555445555444444444000044444444455554455554444444440000444444444555544444445554444440
05444445554444444444444444440044440044444444444444444444444400444400444444444444444444444444004444004444444444444444445554444450
05554444444444444444444554004444444400455444444444444445540044444444004554444444444444455400444444440045544444444444444444445550
05550544444445444444445500444444444444005544444444444455004444444444440055444444444444550044444444444400554444444454444444505550
05550555444445544444440044444444444444440044444444444400444444444444444400444444444444004444444444444444004444444554444455505550
05550555055444444444004444444444444444444400444444440044444444444444444444004444444400444444444444444444440044444444455055505550
05550555005554444400444444445544445544444444004444004444444455444455444444440044440044444444554444554444444400444445550055505550
05550555505505540044444444455544445554444444440000444444444555444455544444444400004444444445554444555444444444004550550555505550
__map__
0006060606060606060606060606060606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000025262700000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000002614151400000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006060606060606060606060606060606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
