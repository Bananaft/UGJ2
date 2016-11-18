#include "freelookCam.as";
Scene@ scene_;
Node@ camNode;
IntVector2 gres = IntVector2(640,360);

Viewport@ rttViewport;
Viewport@ logVpt;
RenderSurface@ surface;
Texture2D@ renderTexture;
Texture2D@ logTex;
Vector3 camVel = Vector3(0.,0.,0.);

RenderPath@ renderpath;
bool bmenu = false;
bool blvl = false;
int ilvl = 0;

float yaw = 0.0f; // Camera ya

void Start()
{
	cache.autoReloadResources = true;
	scene_ = Scene();

	CreateConsoleAndDebugHud();

	SubscribeToEvent("KeyDown", "HandleKeyDown");
	SubscribeToEvent("Update", "HandleUpdate");
	
	setupTitle();
	
}

void setupTitle()
{
	

	Node@ inroNode = scene_.CreateChild("intNode");
	intro@ introObj = cast<intro>(inroNode.CreateScriptObject(scriptFile, "intro"));
    introObj.Init();
}

void setupMenu()
{
	ui.Clear();
		
	Node@ menuNode = scene_.CreateChild("menuNode");
	menu@ menuObj = cast<menu>(menuNode.CreateScriptObject(scriptFile, "menu"));
    menuObj.Init();
}

void startLevel(int lvl)
{
	setupLevel(lvl);
}

void setupLevel(int lvl)
{
	

	
  //SCENE
	scene_.CreateComponent("Octree");
	
//	renderer.hdrRendering = true;
	
	Node@ zoneNode = scene_.CreateChild("Zone");
    Zone@ zone = zoneNode.CreateComponent("Zone");
    zone.boundingBox = BoundingBox(-20000.0f, 20000.0f);
    zone.ambientColor = Color(0.5f, 0.5f, 0.5f);
	zone.fogColor = Color(0.8f, 0.2f, 0.5f);
	
	camNode = scene_.CreateChild("CamNode");
	Camera@ camera = camNode.CreateComponent("Camera");
	camNode.position = Vector3(10,20,-30);
	camera.farClip = 200;
	jetpack@ flcam = cast<jetpack>(camNode.CreateScriptObject(scriptFile, "jetpack"));
    flcam.Init();
	
	Node@ fakeboxNode = scene_.CreateChild("Plane");
	StaticModel@ fakeboxObject = fakeboxNode.CreateComponent("StaticModel");
	fakeboxObject.model = cache.GetResource("Model", "Models/Sphere.mdl");
	
	/*Viewport@ mainVP = Viewport(scene_, camera);
	renderer.viewports[0] = mainVP;
	
	renderpath = mainVP.renderPath.Clone();

	renderpath.Load(cache.GetResource("XMLFile","RenderPaths/Deferred.xml"));
	
	
	renderer.viewports[0].renderPath = renderpath;*/
	
	
	
	renderTexture = Texture2D();
    renderTexture.SetSize(gres.x, gres.y, GetRGBFormat(), TEXTURE_RENDERTARGET);
    renderTexture.filterMode = FILTER_NEAREST;
	
	surface = renderTexture.renderSurface;
    rttViewport = Viewport(scene_, camNode.GetComponent("Camera"));
	rttViewport.rect = IntRect(0,0,gres.x,gres.y);
	
	
	surface.viewports[0] = rttViewport;
    surface.updateMode = SURFACE_UPDATEALWAYS;
	
	logTex = Texture2D();
    logTex.SetSize(1, 1, GetRGBAFormat(), TEXTURE_RENDERTARGET);
    logTex.filterMode = FILTER_NEAREST;
	
	RenderSurface@ surface2 = logTex.renderSurface;
    logVpt = Viewport(scene_, camNode.GetComponent("Camera"));
	logVpt.rect = IntRect(0,0,1,1);
	
	RenderPath@ rndpth = rttViewport.renderPath.Clone();
	RenderPath@ rndpth2 = logVpt.renderPath.Clone();
	
	if (lvl == 1)
	{
		rndpth.Load(cache.GetResource("XMLFile","RenderPaths/lv1.xml"));
		rndpth2.Load(cache.GetResource("XMLFile","RenderPaths/logic.xml"));
	} else if (lvl == 2) {
		rndpth.Load(cache.GetResource("XMLFile","RenderPaths/lv2.xml"));
		rndpth2.Load(cache.GetResource("XMLFile","RenderPaths/logic.xml"));
		
	}
		
	rttViewport.renderPath = rndpth;
	
	logVpt.renderPath = rndpth2;
	
	surface2.viewports[0] = logVpt;
    surface2.updateMode = SURFACE_UPDATEALWAYS;
	
	
	Sprite@ screen = Sprite();
	screen.texture = renderTexture;
	screen.size = gres * 2;
	screen.hotSpot = gres;
	screen.verticalAlignment = VA_CENTER;
	screen.horizontalAlignment = HA_CENTER;
	ui.root.AddChild(screen);
	
	
	Sprite@ screen2 = Sprite();
	screen2.texture = logTex;
	screen2.size = IntVector2(10,10);
	
	ui.root.AddChild(screen2);
	
	UIElement@ LegendNode = ui.root.CreateChild("UIElement");
	LegendNode.SetPosition(200 , 10);
	LegendNode.horizontalAlignment = HA_LEFT;
	LegendNode.verticalAlignment = VA_TOP;
	
	Text@ helpText = LegendNode.CreateChild("Text");
	helpText.SetFont(cache.GetResource("Font", "Fonts/Anonymous Pro.ttf"), 10);
	helpText.horizontalAlignment = HA_LEFT;
	helpText.verticalAlignment = VA_TOP;
	helpText.SetPosition(0,0);
	helpText.color = Color(1,1,0.5);;
	helpText.text =
					"Hello! \n"
					"F2 - show profiler \n"
					"F12 - take screenshot \n\n";
}

void CreateConsoleAndDebugHud()
{
    // Get default style
    XMLFile@ xmlFile = cache.GetResource("XMLFile", "UI/DefaultStyle.xml");
    if (xmlFile is null)
        return;

    // Create console
    Console@ console = engine.CreateConsole();
    console.defaultStyle = xmlFile;
    console.background.opacity = 0.8f;

    // Create debug HUD
    DebugHud@ debugHud = engine.CreateDebugHud();
    debugHud.defaultStyle = xmlFile;

}

void HandlePostRenderUpdate(StringHash eventType, VariantMap& eventData)
    {
		
    }
	
void HandleUpdate(StringHash eventType, VariantMap& eventData)
{
	if (bmenu){
		scene_.RemoveAllChildren();
		setupMenu();
		bmenu = false;
	}
	
	if (blvl){
		scene_.RemoveAllChildren();
		startLevel(ilvl);
		blvl = false;
	}
}
	
void HandleKeyDown(StringHash eventType, VariantMap& eventData)
{	
	
    int key = eventData["Key"].GetInt();

    // Close console (if open) or exit when ESC is pressed
    if (key == KEY_ESCAPE)
    {
        if (console.visible)

            console.visible = false;
    }

    // Toggle console with F1
    else if (key == 96)
        console.Toggle();

    // Toggle debug HUD with F2
    else if (key == KEY_F2)
        debugHud.ToggleAll();

    // Take screenshot
    else if (key == KEY_F12)
	{
		Image@ screenshot = Image();
		graphics.TakeScreenShot(screenshot);
		// Here we save in the Data folder with date and time appended
		screenshot.SavePNG(fileSystem.programDir + "Data/Screenshot_" +
			time.timeStamp.Replaced(':', '_').Replaced('.', '_').Replaced(' ', '_') + ".png");
	}
	

}

class jetpack : ScriptObject
{
float yaw = 0.0f; // Camera yaw angle
float pitch = 0.0f; // Camera pitch angle
float roll = 0.0f;


void Init()
    {

        //node.position = Vector3(0,0,0);
    }

void Update(float timeStep)
	{
        // Do not move if the UI has a focused element (the console)
        if (ui.focusElement !is null)
            return;
        Camera@ cam = node.GetComponent("camera");
        // Movement speed as world units per second
        float MOVE_SPEED = 20.;
  
        // Mouse sensitivity as degrees per pixel
        const float MOUSE_SENSITIVITY = 0.1 * 1/cam.zoom;
		Vector3 thrust = Vector3(0.,0.,0.);
		
        // Read WASD keys and move the camera scene node to the corresponding direction if they are pressed
        if (input.keyDown['W'])
            thrust += Vector3(0.0f, 0.0f, 1.0f);
        if (input.keyDown['S'])
            thrust += Vector3(0.0f, 0.0f, -1.0f);
        if (input.keyDown['A'])
            thrust += Vector3(-1.0f, 0.0f, 0.0f);
        if (input.keyDown['D'])
            thrust += Vector3(1.0f, 0.0f, 0.0f);
      			
		if (input.keyDown['R'])
           node.position = Vector3(0.0f , 14.0f , -20.0f);
		   

		   
		if (input.mouseButtonPress[MOUSEB_LEFT])
		{
		
		}
		
		if (input.mouseButtonPress[MOUSEB_RIGHT])
		{
			
		}
		thrust.Normalize();
		camVel += node.rotation * thrust * time.timeStep * MOVE_SPEED;

		Image@ img =logTex.GetImage();
		Color px = img.GetPixel(0,0);
		Vector3 normal = Vector3(px.r,px.g,px.b);
		float dist = px.a;
		
		camVel.y -= 9.8 * time.timeStep;
		camNode.position += camVel * time.timeStep;
		
		if (input.keyDown[KEY_SPACE])
		{
			if(dist < 0.99) camVel.y += 60  * time.timeStep;
			else camVel.y += 8. * time.timeStep;
		}
		
		if (dist<0.4)
		{
			//camVel = normal * camVel.length * 0.8;
			camVel.y = Max(camVel.y,0.);
			camVel += normal * 40.  *  time.timeStep;
			//camVel.y += 2. * time.timeStep;
			
			
		}
		
		camVel *= 1. - time.timeStep;

            // Use this frame's mouse motion to adjust camera node yaw and pitch. Clamp the pitch between -90 and 90 degrees
        IntVector2 mouseMove = input.mouseMove;
        yaw += MOUSE_SENSITIVITY * mouseMove.x;
        pitch += MOUSE_SENSITIVITY * mouseMove.y;
        pitch = Clamp(pitch, -90.0f, 90.0f);

         // Construct new orientation for the camera scene node from yaw and pitch. Roll is fixed to zero
        node.rotation = Quaternion(pitch, yaw, roll);

        int mousescroll = input.mouseMoveWheel;
        cam.zoom = Clamp(cam.zoom + mousescroll * cam.zoom * 0.2, 0.8 , 20.0 );
		//log.Info(node.position.y);
        //check terrain collision
        //Vector3 campos = node.position;
        //Terrain@ terr = scene.GetChild("terrain").GetComponent("terrain");
        //float ter_height = terr.GetHeight(campos) + 0.9;
        //if (campos.y<ter_height) node.position = Vector3(campos.x, ter_height, campos.z);
		
		if (input.keyPress[KEY_ESCAPE])
		{
			bmenu = true;
			self.Remove();
			node.Remove();
		}
    }



}

class intro : ScriptObject
{
	Sprite@ splash;
	Sprite@ splash2;
	Sprite@ story;
	
	void Init()
    {
		Texture2D@ splashTex = cache.GetResource("Texture2D", "Textures/teamlogo.png");


		splash = Sprite();
		splash.texture = splashTex;
		splash.size = IntVector2(256,256);
		splash.hotSpot = IntVector2(128, 128);
		splash.verticalAlignment = VA_CENTER;
		splash.horizontalAlignment = HA_CENTER;
		ui.root.AddChild(splash);
		splash.opacity = 0.;
		
		Texture2D@ splashTex2 = cache.GetResource("Texture2D", "Textures/sndpls.png");
		splashTex2.filterMode = FILTER_NEAREST;

		splash2 = Sprite();
		splash2.texture = splashTex2;
		splash2.size = IntVector2(512,512);
		splash2.hotSpot = IntVector2(256, 256);
		splash2.verticalAlignment = VA_CENTER;
		splash2.horizontalAlignment = HA_CENTER;
		ui.root.AddChild(splash2);
		splash2.opacity = 0.;
		
		Texture2D@ storyTex = cache.GetResource("Texture2D", "Textures/story.png");
		storyTex.filterMode = FILTER_NEAREST;

		story = Sprite();
		story.texture = storyTex;
		story.size = IntVector2(256 * 4,1024 * 4);
		story.hotSpot = IntVector2(512, 0);
		story.verticalAlignment = VA_CENTER;
		story.horizontalAlignment = HA_CENTER;
		ui.root.AddChild(story);
		story.opacity = 0.;
	}
	
	void Update(float timeStep)
	{
		if (1.<time.elapsedTime && time.elapsedTime<2.)
		{
			splash.opacity = time.elapsedTime-1.;
		} else if (time.elapsedTime>3.)
		{
			splash.opacity = 1.-(time.elapsedTime-3.);
		} 
		
		if (4.<time.elapsedTime && time.elapsedTime<5.)
		{
			splash2.opacity = time.elapsedTime-4.;
		} else if (time.elapsedTime>6.)
		{
			splash2.opacity = 1.-(time.elapsedTime-6.);
		} 
		
		if (7.<time.elapsedTime && time.elapsedTime<8.)
		{
			story.opacity = time.elapsedTime-7.;
		}
				
		if (7.<time.elapsedTime)
		{
			story.position = Vector2(0. , story.position.y - 25.*timeStep);
		}
		
		if (input.keyPress[KEY_SPACE] || input.mouseButtonPress[MOUSEB_LEFT])
		{
			ui.Clear();
			setupMenu();
			self.Remove();
			node.Remove();
		}
		
	}

}

class menu : ScriptObject
{	
	Sprite@ lv1;
	Sprite@ lv2;
	
	Vector2 lv1pos = Vector2(-400,0.);
	Vector2 lv2pos = Vector2(400,0.);
	
	Sprite@ cur;
	bool noext = false;
	
	void Init()
    {
		Texture2D@ lv1Tex = cache.GetResource("Texture2D", "Textures/lv1.png");
		lv1Tex.filterMode = FILTER_NEAREST;

		lv1 = Sprite();
		lv1.texture = lv1Tex;
		lv1.size = IntVector2(256,256);
		lv1.hotSpot = IntVector2(128, 128);
		lv1.position = lv1pos;
		lv1.verticalAlignment = VA_CENTER;
		lv1.horizontalAlignment = HA_CENTER;
		
		ui.root.AddChild(lv1);
		
		Texture2D@ lv2Tex = cache.GetResource("Texture2D", "Textures/lv2.png");
		lv2Tex.filterMode = FILTER_NEAREST;

		lv2 = Sprite();
		lv2.texture = lv2Tex;
		lv2.size = IntVector2(256,256);
		lv2.hotSpot = IntVector2(128, 128);
		lv2.position = Vector2(400,0.);
		lv2.verticalAlignment = VA_CENTER;
		lv2.horizontalAlignment = HA_CENTER;
		
		ui.root.AddChild(lv2);
		
		Texture2D@ curTex = cache.GetResource("Texture2D", "Textures/cur.png");
		

		cur = Sprite();
		cur.texture = curTex;
		cur.size = IntVector2(64,64);
		//cur.hotSpot = IntVector2(128, 128);
		
		cur.verticalAlignment = VA_CENTER;
		cur.horizontalAlignment = HA_CENTER;
		cur.opacity = 0.99;
		ui.root.AddChild(cur);
		
	}
	
	void Update(float timeStep)
	{
		IntVector2 mouseMove = input.mouseMove;
		cur.position += Vector2(mouseMove.x,mouseMove.y);
		
		if (cur.position.x > graphics.width/2.1) cur.position -= Vector2(cur.position.x - graphics.width/2.1, 0 );
		if (cur.position.x < -graphics.width/2.1) cur.position += Vector2(-cur.position.x - graphics.width/2.1, 0 );
		if (cur.position.y > graphics.height/2.1) cur.position -= Vector2(0., cur.position.y - graphics.height/2.1);
		if (cur.position.y < -graphics.height/2.1) cur.position += Vector2(0., -cur.position.y - graphics.height/2.1);
		
		Vector2 lv1l = lv1.position - cur.position;
		Vector2 lv2l = lv2.position - cur.position;
		
		if (lv1l.length<200)
		{
			lv1.position = lv1pos + (Vector2(10 * Sin(time.elapsedTime * 9000),10 * Sin(time.elapsedTime * 792.222)));
			if (input.mouseButtonPress[MOUSEB_LEFT]){
				ilvl = 1;
				blvl = true;
				self.Remove();
			}
			
		} else lv1.position = lv1pos;
		
		if (lv2l.length<200)
		{
			lv2.position = lv2pos + (Vector2(10 * Sin(time.elapsedTime * 9000),10 * Sin(time.elapsedTime * 792.222)));
			if (input.mouseButtonPress[MOUSEB_LEFT]){
				ilvl = 2;
				blvl = true;
				self.Remove();
			}
			
		} else lv2.position = lv2pos;
		
		if (input.keyPress[KEY_ESCAPE] && noext) engine.Exit();
		noext = true;
	}
	
}