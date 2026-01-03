bitmaps["day"] := Map()
bitmaps["day"]["grass"] := Gdip_CreateBitmap(5, 5), G := Gdip_GraphicsFromImage(bitmaps["night"]["grass"]), Gdip_GraphicsClear(G, 0xFF3F9A4A), Gdip_DeleteGraphics(G)
bitmaps["day"]["snow"] := Gdip_CreateBitmap(5, 5), G := Gdip_GraphicsFromImage(bitmaps["day"]["snow"]), Gdip_GraphicsClear(G, 0xFFBEDDEE), Gdip_DeleteGraphics(G)

bitmaps["day"]["dande"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAYAAADgzO9IAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAA9SURBVBhXY9QrtfrPyPCfAQ4YIRQTiPgP5KFjsAQcQFWDABMjmAfESIIgwAQThxBQWaCVTEjWQgFIkoEBAArdCfHDfRoXAAAAAElFTkSuQmCC")
bitmaps["day"]["stump"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJCAYAAADgkQYQAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsEAAA7BAbiRa+0AAABASURBVChTY7SZ6/WfgQBggtJ4AUFF//4Ra9I/JiaG/4yMUC4mAEoDTQI6m/E/frczMYJUEQBMhEwBASIczsAAAKP1DDQ9bA0AAAAAAElFTkSuQmCC")
bitmaps["day"]["pa"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJCAYAAADgkQYQAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsEAAA7BAbiRa+0AAABKSURBVChTY1QtMvnPyPCfAYRwASawAhBghFDYABOUhgCQQiyKURXBAJpC7IpAAEkhUBEOO0AAKoxkEg7FQCEs1mEqxu0muGIGBgAPyATqH7zI/gAAAABJRU5ErkJggg==")
bitmaps["day"]["clovb"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAgAAAAHCAYAAAA1WQxeAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsEAAA7BAbiRa+0AAABKSURBVBhXfY7RDYAwCEShdTwHcD/nLOch5UPS+pILBF4Iet4XpHX5ADCsxtU7sBFJVJloQ0iqdLQiOOUaFZqriE3hF6Pg3+4A5AF50BZQygGgRAAAAABJRU5ErkJggg==")
bitmaps["day"]["ant"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAYAAADED76LAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsEAAA7BAbiRa+0AAAA1SURBVChTY1S4KPafAStgBJNMDIxABlYMUcMEVoYHMEEV4sSETcBuPxQDzcBvAlANASsYGAAwDgI9KuYaygAAAABJRU5ErkJggg==")

bitmaps["night"] := Map()
bitmaps["night"]["snow"] := Gdip_CreateBitmap(5, 5), G := Gdip_GraphicsFromImage(bitmaps["night"]["snow"]), Gdip_GraphicsClear(G, 0xFF56646B), Gdip_DeleteGraphics(G)
bitmaps["night"]["grass"] := Gdip_CreateBitmap(5, 5), G := Gdip_GraphicsFromImage(bitmaps["night"]["grass"]), Gdip_GraphicsClear(G, 0xFF1C4005), Gdip_DeleteGraphics(G)