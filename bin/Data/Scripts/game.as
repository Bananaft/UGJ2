#include "freelookCam.as";
Scene@ scene_;
Node@ camNode;

//SoundPlayer@ player = SoundPlayer();

IntVector2 gres = IntVector2(640,360);

Viewport@ rttViewport;
Viewport@ logVpt;

RenderSurface@ surface;
Texture2D@ renderTexture;
Texture2D@ logTex;

Vector3 camVel = Vector3(0.,0.,0.);

bool bmenu = false;
bool blvl = false;
bool bdebrif = false;
int ilvl = 0;
int dlbtogo;
int lvlphase;
float worldPhase = 0.;
float worldAnim = 0.;
float worldTPhase = 0.;
float worldPhaseSpeed = 5.0;
float worldAnimSpeed = 0.0;
int crystals = 0;
int numcrystals = 0;

bool spawnCrystls = false;

float yaw = 0.0f; // Camera ya
Sprite@ fuelSprite;
float fuel;
float maxfuel = 100.;
Sprite@ healthSprite;
float health;
float maxhealth = 100.;

float lavaLevel = -400;
float lavaTLevel = -400;
float lavaSpeed = 0;
float paingain = 0.;
int crystalstogo = 25;

bool portal = false;
Vector2 portalspeed;
Vector2 portalpos;
Node@ portalNode;

Node@ lavaNode;
float worldded = 180;

void Start()
{
	cache.autoReloadResources = true;
	scene_ = Scene();
	
	scene_.CreateComponent("Octree");
//	scene_.CreateComponent("PhysicsWorld"):

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

void setupDebrif()
{
	ui.Clear();
		
	Node@ dNode = scene_.CreateChild("dNode");
	debrief@ dObj = cast<debrief>(dNode.CreateScriptObject(scriptFile, "debrief"));
    dObj.Init();
}

void startLevel(int lvl)
{
	setupLevel(lvl);
}

void setupLevel(int lvl)
{
	

	
  //SCENE
	
	
//	renderer.hdrRendering = true;
	
	 worldPhase = 0.;
	 worldAnim = 0.;
	 worldTPhase = 0.;
	 worldPhaseSpeed = 5.0;
	 worldAnimSpeed = 0.0;
	 crystals = 0;
	 
	lavaLevel = -400;
	lavaTLevel = -400;
	lavaSpeed = 0;
	fuel = 20;
	health = 100;
	 numcrystals = 0;
	spawnCrystls = false;
	 worldded = 180;
	camVel = Vector3(0.,-50.,220.);

	Node@ zoneNode = scene_.CreateChild("Zone");
    Zone@ zone = zoneNode.CreateComponent("Zone");
    zone.boundingBox = BoundingBox(-20000.0f, 20000.0f);
    zone.ambientColor = Color(0.5f, 0.5f, 0.5f);
	zone.fogColor = Color(0.8f, 0.2f, 0.5f);
	
	camNode = scene_.CreateChild("CamNode");
	Camera@ camera = camNode.CreateComponent("Camera");
	camNode.position = Vector3(0,50,-340);
	camera.farClip = 200;
	jetpack@ flcam = cast<jetpack>(camNode.CreateScriptObject(scriptFile, "jetpack"));
    flcam.Init();
	
	//Node@ fakeboxNode = camNode.CreateChild("Plane");
	//fakeboxNode.scale = Vector3(20000.0f, 20000.0f, 20000.0f);
	//StaticModel@ fakeboxObject = fakeboxNode.CreateComponent("StaticModel");
	//fakeboxObject.model = cache.GetResource("Model", "Models/Box.mdl");
	//Node@ fakeboxNode = scene_.CreateChild("Plane");
	//StaticModel@ fakeboxObject = fakeboxNode.CreateComponent("StaticModel");
	//fakeboxObject.model = cache.GetResource("Model", "Models/Sphere.mdl");
	//fakeboxNode.scale = Vector3(1.,1.,1.);
	
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
		rndpth2.Load(cache.GetResource("XMLFile","RenderPaths/logic1.xml"));

	} else if (lvl == 2) {
		rndpth.Load(cache.GetResource("XMLFile","RenderPaths/lv2.xml"));
		rndpth2.Load(cache.GetResource("XMLFile","RenderPaths/logic2.xml"));
		
	}
	//rndpth.shaderParameters["ANIM"] = Variant(500.);
		
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
	
	Texture2D@ fuelTex = cache.GetResource("Texture2D", "Textures/fuel.png");
	fuelSprite = Sprite();
	fuelSprite.texture = fuelTex;
	fuelSprite.size = IntVector2(32,16);
	fuelSprite.position = Vector2(0,-20);
	fuelSprite.verticalAlignment = VA_TOP;
	fuelSprite.horizontalAlignment = HA_LEFT;
	screen.AddChild(fuelSprite);
	
	Text@ ftxt = fuelSprite.CreateChild("Text");
	ftxt.SetFont(cache.GetResource("Font", "Fonts/Anonymous Pro.ttf"), 20);
	ftxt.color = Color(0.,0.,0.);
	ftxt.text = "PROPELLANT";
	ftxt.position = IntVector2(5,-6);
	
	Texture2D@ healthTex = cache.GetResource("Texture2D", "Textures/health.png");
	healthSprite = Sprite();
	healthSprite.texture = healthTex;
	healthSprite.size = IntVector2(32,16);
	healthSprite.position = Vector2(0,-40);
	healthSprite.verticalAlignment = VA_TOP;
	healthSprite.horizontalAlignment = HA_LEFT;
	screen.AddChild(healthSprite);
	
	Text@ htxt = healthSprite.CreateChild("Text");
	htxt.SetFont(cache.GetResource("Font", "Fonts/Anonymous Pro.ttf"), 20);
	htxt.color = Color(0.,0.,0.);
	htxt.text = "HEALTH";
	htxt.position = IntVector2(5,-6);
	
	Sprite@ screen2 = Sprite();
	screen2.texture = logTex;
	screen2.size = IntVector2(10,10);
	
	ui.root.AddChild(screen2);
	

	spawnDolboshka(Vector3(0.,3.,0.),0.);
	dlbtogo = 1;
	lvlphase = 1;
		
	lavaNode = scene_.CreateChild("lavaNode");
	lavaNode.position = Vector3(0,-40,0);
	lavaNode.scale = Vector3(450,0,450);
	StaticModel@ lavamodel = lavaNode.CreateComponent("StaticModel");
	lavamodel.model = cache.GetResource("Model", "Models/plane.mdl");
	
	Material@ lavamat = cache.GetResource("Material", "Materials/lava.xml");
	lavamodel.material = lavamat;
	
	

}

void spawnDolboshka(Vector3 pos, float spd)
{
	Node@ dlbnNode = scene_.CreateChild("dlbNode");
	dlbnNode.position = pos;
	dolboshka@ dlb = cast<dolboshka>(dlbnNode.CreateScriptObject(scriptFile, "dolboshka"));
	StaticModel@ dlbmodel = dlbnNode.CreateComponent("StaticModel");
	dlbmodel.model = cache.GetResource("Model", "Models/dolboshka.mdl");
	
	Material@ dlbmat = cache.GetResource("Material", "Materials/dlbmat.xml");
	dlbmodel.material = dlbmat;
	
	dlb.alt = pos.y;
	dlb.speed = spd;
	dlb.Init();
}

void spawnZloboshka(Vector3 pos, float spd)
{
	Node@ dlbnNode = scene_.CreateChild("dlbNode");
	dlbnNode.position = pos;
	zloboshka@ dlb = cast<zloboshka>(dlbnNode.CreateScriptObject(scriptFile, "zloboshka"));
	StaticModel@ dlbmodel = dlbnNode.CreateComponent("StaticModel");
	dlbmodel.model = cache.GetResource("Model", "Models/zloboshka.mdl");
	dlbnNode.scale = Vector3( 0.6, 0.6, 0.6);
	Material@ dlbmat = cache.GetResource("Material", "Materials/zlbmat.xml");
	dlbmodel.material = dlbmat;
	Light@ zlbLight = dlbnNode.CreateComponent("Light");
	zlbLight.range = 20;
	zlbLight.color = Color(2.,0.2,0.03) * 4.;
	
	dlb.alt = pos.y;
	dlb.speed = spd;
	dlb.Init();
}

void spawnCrystal(Vector3 pos)
{
	Node@ dlbnNode = scene_.CreateChild("dlbNode");
	dlbnNode.position = pos;
	//dolboshka@ dlb = cast<dolboshka>(dlbnNode.CreateScriptObject(scriptFile, "dolboshka"));
	StaticModel@ dlbmodel = dlbnNode.CreateComponent("StaticModel");
	dlbmodel.model = cache.GetResource("Model", "Models/crystal.mdl");
	
	Material@ dlbmat = cache.GetResource("Material", "Materials/crs.xml");
	dlbmodel.material = dlbmat;
	
	crystal@ crst = cast<crystal>(dlbnNode.CreateScriptObject(scriptFile,"crystal"));
	crst.Init();
	numcrystals ++;
}

void updateWorld (float wphase, float wanim)
{
	RenderPath@ renderpath = rttViewport.renderPath.Clone();
	RenderPathCommand rpc;
	renderpath.shaderParameters["ANIM"] = wanim;
	renderpath.shaderParameters["PHASE"] = wphase;
	
	if (portal)
	{
		Vector3 ppos = Vector3(portalpos.x,portalpos.y, worldded);
		renderpath.shaderParameters["PPOS"] = Variant(ppos);
	}
	rttViewport.renderPath = renderpath;
	
	renderpath = logVpt.renderPath.Clone();
	
	renderpath.shaderParameters["ANIM"] = wanim;
	renderpath.shaderParameters["PHASE"] = wphase;
	
	if (portal)
	{
		Vector3 ppos = Vector3(portalpos.x,portalpos.y, worldded);
		renderpath.shaderParameters["PPOS"] = Variant(ppos);
	}

	logVpt.renderPath = renderpath;
}

/*void setWorld (float wphase, float wanim)
{
	RenderPath@ renderpath = rttViewport.renderPath.Clone();
	RenderPathCommand rpc;
	
	for (int i=3; i<6; i++)
	{
		rpc = renderpath.commands[i];
		//rpc.pixelShaderDefines = "PREMARCH FCTYP";
		renderpath.commands[i] = rpc;
	}
	rpc = renderpath.commands[6];
	//rpc.pixelShaderDefines = "DEFERRED FCTYP";
	renderpath.commands[6] = rpc;
	rttViewport.renderPath = renderpath;
	
	renderpath = logVpt.renderPath.Clone();
	
	rpc = renderpath.commands[1];
	//rpc.pixelShaderDefines = "DEFERRED FCTYP";
	renderpath.commands[1] = rpc;
	logVpt.renderPath = renderpath;
}*/

void switchPhase()
{
	Vector3 cpos = camNode.position;
	cpos.y = 0.;
	
	RenderPath@ renderpath;
	
	if (ilvl == 1)
	{
		jetpack@ player2 = cast<jetpack>(camNode.GetScriptObject("jetpack"));
			
		if (lvlphase == 2)
		{
			spawnDolboshka(cpos + Vector3(50.,4.,0.),5.);
			spawnDolboshka(cpos + Vector3(-50.,2.,0.),5.);
			dlbtogo = 2;
			worldTPhase = 25.;
			
			player2.PlaySound("Sounds/dl_2.wav");
		}
		
		else if (lvlphase == 3)
		{
			spawnDolboshka(cpos + Vector3(150.,1.,0.),12.);
			spawnDolboshka(cpos + Vector3(-150.,1.,0.),12.);
			spawnDolboshka(cpos + Vector3(0.,1.,150.),12.);
			dlbtogo = 3;
			worldTPhase = 35.;
			
			player2.PlaySound("Sounds/dl_3.wav");
		}	
		
		else if (lvlphase == 4)
		{
			spawnZloboshka(cpos + Vector3(150.,-9.,0.),15.);
			spawnZloboshka(cpos + Vector3(-150.,-7.,0.),15.);
			spawnDolboshka(cpos + Vector3(150.,-2.,15.),15.);
			spawnDolboshka(cpos + Vector3(-150.,-0.,15.),15.);
			spawnDolboshka(cpos + Vector3(0.,2.,150.),15.);
			//spawnCrystls = true;
			dlbtogo = 3;
			worldTPhase = 55.;
			worldPhaseSpeed = 1.;
			
			renderpath = rttViewport.renderPath.Clone();
			
			renderpath.shaderParameters["FOGCOL"] = Variant(Vector3(0.06,0.25,0.3));

			rttViewport.renderPath = renderpath;
			
			player2.PlaySound("Sounds/dl_4.wav");
		}
		
		else if (lvlphase == 5)
		{
			//spawnZloboshka(cpos + Vector3(50.,-9.,0.),15.);
			//spawnZloboshka(cpos + Vector3(-50.,-7.,0.),15.);
			spawnZloboshka(cpos + Vector3(150.,-9.,0.),15.);
			spawnZloboshka(cpos + Vector3(-150.,-7.,0.),15.);
			spawnDolboshka(cpos + Vector3(50.,-5.,15.),15.);
			spawnDolboshka(cpos + Vector3(-50.,0.,15.),15.);
			spawnDolboshka(cpos + Vector3(0.,7.,50.),15.);
			//spawnCrystls = true;
			dlbtogo = 3;
			worldTPhase = 80.;
			worldAnimSpeed = 0.2;
			
			
			player2.PlaySound("Sounds/dl_5.wav");
		}
		else if (lvlphase == 6)
		{
			spawnCrystls = true;
			
			renderpath = rttViewport.renderPath.Clone();
			
			renderpath.shaderParameters["FOGCOL"] = Variant(Vector3(0.7,0.8,0.9));

			rttViewport.renderPath = renderpath;
			
			
			player2.PlaySound("Sounds/dl_6.wav");
		}
		else if (lvlphase == 7)
		{
			spawnDolboshka(cpos + Vector3(50.,25.,15.),10.);
			spawnDolboshka(cpos + Vector3(-50.,30.,15.),10.);
			spawnDolboshka(cpos + Vector3(0.,35.,50.),10.);
			
			dlbtogo = 3;
			worldTPhase = 160.;
			worldPhaseSpeed = 0.2;
			lavaLevel = -35;
			lavaTLevel = 0;
			lavaSpeed = 0.6;
			spawnCrystls = false;
			
			renderpath = rttViewport.renderPath.Clone();
			
			renderpath.shaderParameters["FOGCOL"] = Variant(Vector3(0.9,0.6,0.6));

			rttViewport.renderPath = renderpath;
			
			
			player2.PlaySound("Sounds/dl_7.wav");
		}
		
		else if (lvlphase == 8)
		{
			//spawnDolboshka(cpos + Vector3(50.,25.,15.),10.);
			//spawnDolboshka(cpos + Vector3(-50.,30.,15.),10.);
			//spawnDolboshka(cpos + Vector3(0.,35.,50.),10.);
			
			//dlbtogo = 3;
			//worldTPhase = 160.;
			//worldPhaseSpeed = 0.1;
			lavaLevel = -400;
			lavaTLevel = -400;
			lavaSpeed = 0.0;
			spawnCrystls = true;
			crystalstogo = crystals;
			
			renderpath = rttViewport.renderPath.Clone();
			RenderPathCommand rpc;
			
			camNode.position = Vector3( 40,60,40);
			
			for (int i=3; i<6; i++)
			{
				rpc = renderpath.commands[i];
				rpc.pixelShaderDefines = "PREMARCH FCTYP LV2";
				renderpath.commands[i] = rpc;
			}
			rpc = renderpath.commands[6];
			rpc.pixelShaderDefines = "DEFERRED FCTYP LV2";
			renderpath.commands[6] = rpc;
			rttViewport.renderPath = renderpath;
			
			renderpath = logVpt.renderPath.Clone();
			
			rpc = renderpath.commands[0];
			rpc.pixelShaderDefines = "DEFERRED LV2";
			renderpath.commands[0] = rpc;
			logVpt.renderPath = renderpath;
			
			renderpath = rttViewport.renderPath.Clone();

			renderpath.shaderParameters["FOGCOL"] = Variant(Vector3(0.8,0.65,0.6));

			rttViewport.renderPath = renderpath;
			
			
			player2.PlaySound("Sounds/dl_8.wav");
		}
		else if (lvlphase == 9)
		{
			spawnDolboshka(cpos + Vector3(10.,80.,0.),5.);
			
			dlbtogo = 1;
			
			
			player2.PlaySound("Sounds/dl_9.wav");
		}
		
		else if (lvlphase == 10)
		{

			
			spawnZloboshka(cpos + Vector3(150.,-9.,0.),15.);
			spawnZloboshka(cpos + Vector3(-150.,-7.,0.),15.);
			spawnZloboshka(cpos + Vector3(150.,-9.,0.),15.);
			spawnZloboshka(cpos + Vector3(-150.,-7.,0.),15.);
			spawnZloboshka(cpos + Vector3(150.,-9.,0.),15.);
			spawnZloboshka(cpos + Vector3(-150.,-7.,0.),15.);

			
			lavaLevel = -30;
			lavaTLevel = -30;
			
			worldPhase = 250;
			worldTPhase = 250;
			worldAnimSpeed = 2.;
			spawnCrystls = false;
			
			renderpath = rttViewport.renderPath.Clone();
			RenderPathCommand rpc;
			
			camNode.position = Vector3( 0,60,0);
			
			for (int i=3; i<6; i++)
			{
				rpc = renderpath.commands[i];
				rpc.pixelShaderDefines = "PREMARCH PORTAL";
				renderpath.commands[i] = rpc;
			}
			rpc = renderpath.commands[6];
			rpc.pixelShaderDefines = "DEFERRED PORTAL";
			renderpath.commands[6] = rpc;
			rttViewport.renderPath = renderpath;
			
			renderpath = logVpt.renderPath.Clone();
			
			rpc = renderpath.commands[0];
			rpc.pixelShaderDefines = "DEFERRED PORTAL";
			renderpath.commands[0] = rpc;
			logVpt.renderPath = renderpath;
			
			portal = true;
			portalNode = scene_.CreateChild("portalNode");
			
			portalNode.scale = Vector3(10,500,10);
			StaticModel@ portalmodel = portalNode.CreateComponent("StaticModel");
			portalmodel.model = cache.GetResource("Model", "Models/cylinder.mdl");
			
			Material@ prtmat = cache.GetResource("Material", "Materials/beam.xml");
			portalmodel.material = prtmat;
			
			Vector3 ppos = camNode.rotation * Vector3(0.,0.,1.);
			Vector2 pp = Vector2(ppos.x,ppos.z);
			pp.Normalize();
			portalspeed = pp;
			pp *= 100;
			pp += Vector2(camNode.position.x,camNode.position.z);
			portalpos = pp;
			
			renderpath = rttViewport.renderPath.Clone();
			
			renderpath.shaderParameters["FOGCOL"] = Variant(Vector3(0.4,0.7,0.6));

			rttViewport.renderPath = renderpath;
			
			
			player2.PlaySound("Sounds/dl_10.wav");
			
		}
	} else if (ilvl == 2)
	{
		spawnCrystls = true;
	}
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
	
	if (bdebrif){
		scene_.RemoveAllChildren();
		setupDebrif();
		bdebrif = false;
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

SoundSource@ noise;
SoundSource@ walk;
SoundSource@ jet;
SoundSource@ pain;
SoundSource@ heal;

Vector3 exCpos1;
bool hack72 = false;

void Init()
    {
		audio.listener = node.CreateComponent("SoundListener");
        //node.position = Vector3(0,0,0);
		noise = node.CreateComponent("SoundSource");
		Sound@ nsound = cache.GetResource("Sound", "Sounds/Gray_noise.wav");
		noise.Play(nsound);
		noise.gain = 0.0f;
		
		walk = node.CreateComponent("SoundSource");
		Sound@ wsound = cache.GetResource("Sound", "Sounds/walk.wav");
		walk.Play(wsound);
		walk.gain = 0.0f;
		
		jet = node.CreateComponent("SoundSource");
		Sound@ jsound = cache.GetResource("Sound", "Sounds/jet.wav");
		jet.Play(jsound);
		jet.gain = 0.0f;
		
		pain = node.CreateComponent("SoundSource");
		Sound@ psound = cache.GetResource("Sound", "Sounds/pain.wav");
		pain.Play(psound);
		pain.gain = paingain;
		
		heal = node.CreateComponent("SoundSource");
		Sound@ hsound = cache.GetResource("Sound", "Sounds/heal.wav");
		heal.Play(hsound);
		heal.gain = 0.0;
    }

void Update(float timeStep)
	{
        // Do not move if the UI has a focused element (the console)
        //if (ui.focusElement !is null)
          //  return;
		pain.gain = Min(paingain,1.);
		paingain  -= timeStep*2;
		paingain = Max(paingain,0.);
		
        Camera@ cam = node.GetComponent("camera");
        // Movement speed as world units per second
        float MOVE_SPEED = 20.;
		//log.Info(camVel.length);
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
      			
		//if (input.keyDown['R'])
        //   node.position = Vector3(0.0f , 14.0f , -20.0f);
		   
		//if (input.keyDown['T'])
        //  worldPhase = worldTPhase;
		   
		   
		if (input.mouseButtonPress[MOUSEB_LEFT])
		{
		
		}
		
		if (input.mouseButtonDown[MOUSEB_RIGHT])
		{
			cam.zoom = 4.;
		} else {
			cam.zoom = 0.8;
		}
		Quaternion trot; trot.FromEulerAngles(0.,node.rotation.yaw,0.);
		thrust.Normalize();
		camVel += trot * thrust * time.timeStep * MOVE_SPEED;

		Image@ img =logTex.GetImage();
		Color px = img.GetPixel(0,0);
		Vector3 normal = Vector3(px.r,px.g,px.b);
		float dist = px.a;
		
	
		camVel.y -= 9.8 * time.timeStep;
		camNode.position += camVel * time.timeStep;
		//if  (input.keyPress[KEY_F8]) spawnCrystal(node.position);
		
		if (input.keyDown[KEY_SPACE] && fuel > 0.)
		{
			jet.gain += 5. * timeStep;
			
			if(dist < 0.99)
			{
				camVel.y += 60  * time.timeStep;
				jet.gain = Min(jet.gain,2.0);
				fuel -= 50 * timeStep;
			} else {
				camVel.y += 8. * time.timeStep;
				jet.gain = Min(jet.gain,0.1);
				fuel -= 15 * timeStep;
			}
		} else {
			jet.gain -= 0.4 * timeStep;
			jet.gain =  Clamp(jet.gain,0.,1.);
		}
		
		if (dist<0.7)
		{
			//camVel = normal * camVel.length * 0.8;
			if (normal.y>0.3)camVel.y = Max(camVel.y,0.);
			else if (normal.y<-0.3)camVel.y = Min(camVel.y,0.);
			camVel += normal * 20.  *  time.timeStep;
			//camVel.y += 2. * time.timeStep;
			//float dot = camVel.DotProduct(normal);
			//Vector3 refvec = normal*dot*2. - camVel;
			//if (dot>0.2) camVel = refvec;
			
			if (dist<0.3)
			{
				float trs = 0.2;
				if (normal.y>trs)camVel.y = Max(camVel.y,0.);
				else if (normal.y<-trs)camVel.y = Min(camVel.y,0.);
				
				camVel += normal * 50.  *  time.timeStep;
				/*if (normal.x>trs)camVel.x *= -1;// Max(camVel.x,0.);
				else if (normal.x<-trs)camVel.x *= -1;// Min(camVel.x,0.);
				
				if (normal.z>trs)camVel.z *= -1;// Max(camVel.z,0.);
				else if (normal.z<-trs)camVel.z *= -1;// Min(camVel.z,0.);*/
				if (dist<0.05){
					health -= 25 * timeStep;
					paingain = 1.;
				}
			
			}
			
		}
		
		if (dist<0.6)
		{
			walk.gain += 1.0 * timeStep;
		} else {
			walk.gain -= 1.0 * timeStep;
		}
		walk.gain = Clamp( walk.gain,0.,1.);
		
		camVel *= 1. - time.timeStep;

            // Use this frame's mouse motion to adjust camera node yaw and pitch. Clamp the pitch between -90 and 90 degrees
        IntVector2 mouseMove = input.mouseMove;
        yaw += MOUSE_SENSITIVITY * mouseMove.x;
        pitch += MOUSE_SENSITIVITY * mouseMove.y;
        pitch = Clamp(pitch, -90.0f, 90.0f);

         // Construct new orientation for the camera scene node from yaw and pitch. Roll is fixed to zero
        node.rotation = Quaternion(pitch, yaw, roll);

        //int mousescroll = input.mouseMoveWheel;
        //cam.zoom = Clamp(cam.zoom + mousescroll * cam.zoom * 0.2, 0.8 , 20.0 );
		//log.Info(node.position.y);
        //check terrain collision
        //Vector3 campos = node.position;
        //Terrain@ terr = scene.GetChild("terrain").GetComponent("terrain");
        //float ter_height = terr.GetHeight(campos) + 0.9;
        //if (campos.y<ter_height) node.position = Vector3(campos.x, ter_height, campos.z);
		
		if (input.keyPress[KEY_ESCAPE])
		{
			bmenu = true;
			node.RemoveAllComponents();
			//self.Remove();
			//node.Remove();
		}
		
		//noise.gain = Clamp((camVel.length * (0.2 + dist)-12.) * 0.1, 0. ,1.);
/*		if (camVel.length > 19.0)
		{
			noise.gain += 0.2 * timeStep;
			
		} else {
			noise.gain -= 0.5 * timeStep;
		}*/
		
		noise.gain = Pow(camVel.length/26., 5.);
		noise.gain = Clamp(noise.gain,0.,1.);
/*		Color px2;
		for (uint i=0; i<32;i++)
			for (uint u=0; u<32;u++){
				px2 = img.GetPixel(i,u);
				log.Info(String(i));
			}	*/
		if (lvlphase == 7 && camNode.position.y > 70. && hack72 == false)
		{
			PlaySound("Sounds/dl_7_2.wav");
			hack72 = true;
		}
			
		if (spawnCrystls)
		{
			if (px.r < 0.6 && px.r > 0.1 && numcrystals<40)
			{
				spawnCrystal(exCpos1);
				
				//log.Info(exCpos1.y);
			}
			//log.Info(node.position.y);
			
			Vector3 csdir = Vector3(camVel.x,0.,camVel.z);
			Quaternion csrot;
			csrot.FromEulerAngles(0.,30-Random(60),0.);
			csdir = csrot * csdir;
			csdir.Normalize();
			csdir *= 150;
			
			if (lvlphase == 8)
			csdir.y = 30 + Random(20.);
			else
			csdir.y = -20.-Random(30.);
	
			RenderPath@ renderpath = logVpt.renderPath.Clone();
			
			Vector3 checkVec = Vector3(node.position.x,0.,node.position.z);
			checkVec += csdir;
		
			renderpath.shaderParameters["Crsvec1"] = Variant(checkVec);
			//renderpath.shaderParameters["Crsvec2"] = wphase;
			//renderpath.shaderParameters["Crsvec3"] = wphase;

			logVpt.renderPath = renderpath;
			
			exCpos1 = checkVec;
			
		}
		
		if (worldPhase<worldTPhase) worldPhase += worldPhaseSpeed * timeStep;
		worldAnim += worldAnimSpeed * timeStep;
		
		if (lavaLevel<lavaTLevel-0.2) lavaLevel += lavaSpeed * timeStep;
		if (lavaLevel>lavaTLevel+0.2) lavaLevel -= lavaSpeed * timeStep;
		
		updateWorld(worldPhase,worldAnim);
		
		//log.Info(numcrystals);
		//log.Info(crystals);
		
		if (lvlphase == 6 && crystals>6)
		{
			lvlphase ++;
			switchPhase();
		}
		
		if (lvlphase == 8 && crystals>crystalstogo+2)
		{
			lvlphase ++;
			switchPhase();
		}
		
		fuelSprite.size = IntVector2(fuel/maxfuel * gres.x * 2.,16);
		if (fuel<maxfuel)
			fuel += (1-dist) * 125 * timeStep;
			
		fuel = Clamp(fuel,0,maxfuel);
		
		healthSprite.size = IntVector2(health / maxhealth * gres.x * 2.,16);
		if (health<maxhealth && 5.-camVel.length>0. && 1-dist > 0.)
		{
			health += (1-dist) * Max(5.-camVel.length,0.) * 10 * timeStep;
			heal.gain = 0.35;
			
		} else {
			heal.gain = 0.;
		}
		
		if (health<0)
		{
			bdebrif = true;
			node.RemoveAllComponents();
		}
			
		health = Min(health,maxhealth);
		
		lavaNode.position = Vector3(camNode.position.x,lavaLevel,camNode.position.z);
		
		if (node.position.y - 0.2 < lavaLevel)
		{
			camVel = Vector3(camVel.x,Max(camVel.y,0.),camVel.z);
			node.position = Vector3(node.position.x,lavaLevel + 0.2,node.position.z);
			camVel *= 0.94;
			health -= 10 * timeStep;
			paingain = 1.;
		}
		
		if (portal)
		{
			
			Vector2 prane = portalpos - Vector2(camNode.position.x, camNode.position.z);
			//log.Info(prane.length);
			float prange = prane.length;
			if (prange < 5.0)
			{
				lvlphase++;
				bdebrif = true;
				node.RemoveAllComponents();
			}
			
			portalNode.position = Vector3(portalpos.x,200.,portalpos.y);
			float pspeed = 16.8;
			if (prange > worldded)
			{
				pspeed = 5.;
			}
			
			portalpos += portalspeed * pspeed * timeStep;
			Quaternion qt;
			qt.FromEulerAngles(0.,120*timeStep,0.);
			portalNode.Rotate(qt);
			worldded -= 2 * timeStep;
			
			
			
		}
    }
	
	void PlaySound(const String&in soundName)
    {
        SoundSource@ source = node.CreateComponent("SoundSource");
        Sound@ sound = cache.GetResource("Sound", soundName);
        // Subscribe to sound finished for cleaning up the source
        SubscribeToEvent(node, "SoundFinished", "HandleSoundFinished");

        //source.SetDistanceAttenuation(2, 50, 1);
        source.Play(sound);
    }
    
    void HandleSoundFinished(StringHash eventType, VariantMap& eventData)
    {
        SoundSource@ source = eventData["SoundSource"].GetPtr();
        source.Remove();
    }
	
}

class crystal : ScriptObject
{
	void Init()
    {
	}
	
	void Update(float timeStep)
    {
		Vector3 toCam = camNode.position - node.position;
		float range = toCam.length;
		
		if (range < 10.) node.position -= (node.position - camNode.position) * 16. * timeStep;
		
		if (range < 2.)
		{
			jetpack@ player2 = cast<jetpack>(camNode.GetScriptObject("jetpack"));
			player2.PlaySound("Sounds/pickup.wav");
			
			crystals ++; 
			numcrystals --;
			node.Remove();
			
		}
		
		if (range > 220.)
		{
			//crystals ++;
			numcrystals --;
			node.Remove();
			
		}
	}
	
}

class dolboshka : ScriptObject
{
	float alt;
	float speed = 10;
	float phase = 0.;
	Vector2 bhvr;
	
	Vector2 vel;
	SoundSource3D@ zlbsnd;
	bool ded = false;
	float dedtmr = 1;
	
	void Init()
    {
		
        bhvr = Vector2(10 + Random(50),10 + Random(50));
		zlbsnd = node.CreateComponent("SoundSource3D");
		Sound@ ghoul = cache.GetResource("Sound", "Sounds/ghoul.wav");
		zlbsnd.Play(ghoul);
		zlbsnd.farDistance = 80.;
		
    }
	
	void Update(float timeStep)
    {
		node.position = Vector3(node.position.x,alt,node.position.z);
		
		
		
		
		Vector3 toCam = camNode.position - node.position;
		Vector2 heading = Vector2(toCam.x,toCam.z);
		heading.Normalize();
		float range = toCam.length;
		
		//if (input.keyDown['R']) node.position -= (node.position - camNode.position) *0.2;
		
		if(ded)
		{
			zlbsnd.gain -= timeStep;
			node.position += Vector3(vel.x * timeStep + camVel.x * 2 *timeStep,camVel.y * 2 *timeStep,vel.y * timeStep + camVel.z * 2 *timeStep);
			vel *= 0.95;
			Quaternion rotded;
			rotded.FromEulerAngles(Sin(phase)*360 * timeStep,Sin(bhvr.x * 20.)*360 * timeStep,Sin(bhvr.y * 20.)*360 * timeStep);
			node.Rotate(rotded);
			dedtmr -= timeStep;
			
			worldAnim += 8. * timeStep;
			//updateWorld(worldPhase,worldAnim);
			
			if (dedtmr<0.)
			{
				node.Remove();
			}
		} else {
			
			if (range<20)
			{
				heading *= -1;
				phase = Random(360);
			}
			else if (range<100)
			{
				heading = Vector2(Sin(bhvr.x * (time.elapsedTime+phase)),Sin(bhvr.y * time.elapsedTime+phase));
			}
			
			vel += heading * 12. * timeStep;
			
			if (vel.length > speed)
			{
				vel.Normalize();
				vel *= speed;
			}
			
			if (range>200)
			{
				vel = heading * 200.;
			}
			
			node.position += Vector3(vel.x * timeStep,0.,vel.y * timeStep);
			
			Quaternion rot;
			rot.FromEulerAngles(0.,90.*timeStep,0.);
			node.Rotate(rot);
			
			if (range<4.)
			{
				die();
			}
			
		}
		
		
		
    }
	
	void die()
	{
		ded = true;
		dlbtogo--;
		
		//Sound@ sound = cache.GetResource("Sound", "Sounds/hit.wav");
		//SoundSource@ sndSource = node.CreateComponent("SoundSource");
		//sndSource.Play(sound);
		//sndSource.gain = 0.9f;
		//sndSource.autoRemove = true;
		jetpack@ player2 = cast<jetpack>(camNode.GetScriptObject("jetpack"));
		player2.PlaySound("Sounds/hit.wav");
		
		if (dlbtogo == 0)
		{
			lvlphase++;
			switchPhase();
		}				
	}

}

class zloboshka : ScriptObject
{
	float alt;
	float speed = 10;
	float phase = 0.;
	Vector3 bhvr;
	
	Vector3 vel;
	
	bool ded = false;
	float dedtmr = 1;
	float rage = 150;
	float ragetm = 4.;
	
	void Init()
    {
		
        bhvr = Vector3(10 + Random(50),-5 + Random(300),10 + Random(50));
		
		SoundSource3D@ zlbsnd = node.CreateComponent("SoundSource3D");
		Sound@ ghoul = cache.GetResource("Sound", "Sounds/zlb.wav");
		zlbsnd.Play(ghoul);
		zlbsnd.farDistance = 40.;

    }
	
	void Update(float timeStep)
    {
		//node.position = Vector3(node.position.x,alt,node.position.z);
		
		
		
		
		Vector3 toCam = camNode.position - node.position;

		float range = toCam.length;
		if (range > 10 ) toCam.y += 0.2 * range * range;
		rage += (10 - range) * timeStep;
		float boost;
		if (rage < 0.)
		{
			boost = 4.; 
			ragetm -= timeStep;
			if (ragetm < 0.){
				rage = 150.;
				ragetm = 4.;
			}
			
				
		}	else boost = 1.;
		//log.Info(rage);
		
		Vector3 heading = (camNode.position + camVel * 2. * range * timeStep) - node.position;
		heading.Normalize();
		
		if(ded)
		{
			node.position += Vector3(vel.x * timeStep + camVel.x * 2 *timeStep,camVel.y * 2 *timeStep,vel.y * timeStep + camVel.z * 2 *timeStep);
			vel *= 0.95;
			Quaternion rotded;
			rotded.FromEulerAngles(Sin(phase)*360 * timeStep,Sin(bhvr.x * 20.)*360 * timeStep,Sin(bhvr.y * 20.)*360 * timeStep);
			node.Rotate(rotded);
			dedtmr -= timeStep;
			
			//worldAnim += 15. * timeStep;
			//updateWorld(worldPhase,worldAnim);
			
			if (dedtmr<0.)
			{
				node.Remove();
			}
		} else {
			
			if (range<10)
			{
				//heading *= 1;
				phase = Random(360);
			}else if (range<150)
			{
				if (rage<0.) heading += Vector3(Sin(bhvr.x * (time.elapsedTime+phase)),Sin(bhvr.y * (time.elapsedTime+phase)),Sin(bhvr.z * (time.elapsedTime+phase))) * 80. * timeStep;
				else heading += Vector3(Sin(bhvr.x * (time.elapsedTime+phase)),Sin(bhvr.y * (time.elapsedTime+phase)),Sin(bhvr.z * (time.elapsedTime+phase))) * 20. * timeStep;
				
			}else if (range<150)
			{
				heading += Vector3(Sin(bhvr.x * (time.elapsedTime+phase)),Sin(bhvr.y * (time.elapsedTime+phase)),Sin(bhvr.z * (time.elapsedTime+phase))) * 25. * timeStep;
			}
			
			vel += heading * 18. * timeStep;
			
			if (vel.length > speed * boost)
			{
				vel.Normalize();
				vel *= speed * boost;
			}
			
			if (range>200)
			{
				vel = heading * 200.;
			}
			
			node.position += vel * timeStep;
			
			Quaternion rot;
			rot.FromLookRotation(heading,Vector3(0,1,0));
			//rot.FromEulerAngles(0.,90.*timeStep,0.);
			node.rotation = rot;
			
			if (range<4.)
			{
				camVel += ((camNode.position - node.position)+Vector3(0,0.1,0)) * 400. * timeStep;
				health -= 200 * timeStep;
				paingain = 4.;
			}
		
		
			
		}
		
		
		if (lvlphase == 6) ded = true;
    }
}

class intro : ScriptObject
{
	Sprite@ splash;
	Sprite@ splash2;
	Sprite@ story;
	bool playing = false;
	
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
		
		Sound@ startsound = cache.GetResource("Sound", "Sounds/start.wav");
		SoundSource@ soundSource = scene_.CreateComponent("SoundSource");
		soundSource.Play(startsound);
		soundSource.gain = 0.9f;
		//soundSource.autoRemove = true;
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
			if(playing == false)
			{
				PlaySound("Sounds/story.wav");
				playing = true;
			}
			
		}
				
		if (7.<time.elapsedTime)
		{
			story.position = Vector2(0. , story.position.y - 32.*timeStep);
		}
		
		if (input.keyPress[KEY_ESCAPE])
		{
			ui.Clear();
			setupMenu();
			self.Remove();
			
		}
		
	}
	
	void PlaySound(const String&in soundName)
    {
        SoundSource@ source = node.CreateComponent("SoundSource");
        Sound@ sound = cache.GetResource("Sound", soundName);
        // Subscribe to sound finished for cleaning up the source
        SubscribeToEvent(node, "SoundFinished", "HandleSoundFinished");

        //source.SetDistanceAttenuation(2, 50, 1);
        source.Play(sound);
    }
    
    void HandleSoundFinished(StringHash eventType, VariantMap& eventData)
    {
        SoundSource@ source = eventData["SoundSource"].GetPtr();
        source.Remove();
		
		ui.Clear();
		setupMenu();
		self.Remove();
    }

}

class menu : ScriptObject
{	
	Sprite@ lv1;
	//Sprite@ lv2;
	
	Vector2 lv1pos = Vector2(0,-200.);
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
		/*
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
		*/
		Texture2D@ curTex = cache.GetResource("Texture2D", "Textures/cur.png");
		curTex.filterMode = FILTER_NEAREST;

		cur = Sprite();
		cur.texture = curTex;
		cur.size = IntVector2(512,512);
		//cur.hotSpot = IntVector2(128, 128);
		
		cur.verticalAlignment = VA_CENTER;
		cur.horizontalAlignment = HA_CENTER;
		cur.opacity = 0.99;
		ui.root.AddChild(cur);
		cur.position = Vector2(500,200);
		
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
		//Vector2 lv2l = lv2.position - cur.position;
		
		if (lv1l.length<200)
		{
			lv1.position = lv1pos + (Vector2(10 * Sin(time.elapsedTime * 9000),10 * Sin(time.elapsedTime * 792.222)));
			if (input.mouseButtonPress[MOUSEB_LEFT]){
				ilvl = 1;
				blvl = true;
				self.Remove();
			}
			
		} else lv1.position = lv1pos;
		/*
		if (lv2l.length<200)
		{
			lv2.position = lv2pos + (Vector2(10 * Sin(time.elapsedTime * 9000),10 * Sin(time.elapsedTime * 792.222)));
			if (input.mouseButtonPress[MOUSEB_LEFT]){
				ilvl = 2;
				blvl = true;
				self.Remove();
			}
			
		} else lv2.position = lv2pos;
		*/
		if (input.keyPress[KEY_ESCAPE] && noext) engine.Exit();
		noext = true;
	}
	
}

class debrief : ScriptObject
{	
	void Init()
    {
		
		UIElement@ LegendNode = ui.root.CreateChild("UIElement");
		LegendNode.SetPosition(-600 , -150);
		LegendNode.horizontalAlignment = HA_CENTER;
		LegendNode.verticalAlignment = VA_CENTER;
		
		Text@ helpText = LegendNode.CreateChild("Text");
		helpText.SetFont(cache.GetResource("Font", "Fonts/Anonymous Pro.ttf"), 20);
		//helpText.horizontalAlignment = HA_LEFT;
		//helpText.verticalAlignment = VA_TOP;
		helpText.SetPosition(0,0);
		helpText.color = Color(1,1,0.5);;
		
		if (lvlphase == 11)
		{
			helpText.text =
						"Поздравляем! \n"
						"Ты всех победил! \n"
						"Молодец! \n\n"
						"После того как ты прыгнул в портал появился зеленоглазый мужик с чемоданом \n"
						"и сказал, что мол ты всё сделал, как он задумал и положил тебя в стазис на 300 лет.\n"
						"Сказал, что разморозит, когда выйдет следующая часть.\n\n\n"
						
						"Большое спасибо за игру! \n"
						"Ставьте лайки, подписывайтесь на новое видео, пока! \n"
						"https://twitter.com/Bananaft \n";
						
		} else 	if (lvlphase == 10){
			helpText.text =
						"Грустная концовка. \n"
						"Мир патиссонов уничтожен, \n"				
						"но ты погиб вместе с ним. \n"
						"Злобные головёшки прыгнули в портал вместо тебя и убили всех людей. \n";
						
			
		} else {
			helpText.text =
						"Миссия провалена! \n"
						"Земля была вывернута наизнанку через пятое измерение. \n"
						"Все, кого ты знал - погибли. \n\n";	
		}
	}
	void Update(float timeStep)
	{
		if (input.keyPress[KEY_SPACE] || input.mouseButtonPress[MOUSEB_LEFT])
		{
			ui.Clear();
			setupMenu();
			self.Remove();
			
		}
	}
	
}