NZ(menu)
{
    if(menu == "main")
    {
        self addmenu("main", "Main Menu");
        if(self getVerification() > 0) //Verification Higher Than Unverified
        {
            self addOpt("Basic Scripts",::newMenu,"Basic Scripts");
            self addOpt("Menu Theme",::newMenu,"Menu Theme");
            if(self getVerification() > 1) //Verification Higher Than Verified
            {
                if(self getVerification() > 2) //Verification Higher Than VIP
                {
                    if(self getVerification() > 3) //Verification Higher Than Co-Host (Co-Host/Host)
                    {
                        self addOpt("Players Menu",::newMenu,"Players Menu");
                        self addOpt("Developer Options",::newMenu,"Developer Options");
                    }
                }
            }
        }
    }
    if(menu == "Basic Scripts")
    {
        self addMenu("Basic Scripts","Basic Scripts");
            self addOptBool("God Mode",::tc);
            self addOptBool("Unlimited Ammo",::UnlimitedAmmo);
            self addOptBool("Unlimited Equipment",::UnlimitedEquipment);
    }
    if(menu == "Menu Theme")
    {
        self addMenu("Menu Theme","Menu Theme");
            for(a=0;a<level.colorNames.size;a++)self addOpt(level.colorNames[a],::MenuTheme,divideColor(int(level.colors[3*a]),int(level.colors[(3*a)+1]),int(level.colors[(3*a)+2])));
            self addOpt("Smooth Rainbow",::SmoothRainbowTheme);
            self addOpt("Reset",::MenuTheme,divideColor(0,0,255));
    }
    if(menu == "Developer Options")
    {
        self addMenu("Developer Options","Developer Options");
            self addOpt("Disconnect",::disconnect);
    }
    
    self Y(menu);
}

tc() {
    self thread EnableInvulnerability();
}

Y(menu)
{
    if(menu == "Players Menu")
    {
        self addMenu("Players Menu","Players Menu");
            foreach(player in level.players)
                self addOpt("[^2"+player.playerSetting["verification"]+"^7]"+player getName(),::newMenu,player getName()+"options");
    }
    foreach(player in level.players)
    {
        if(menu == player getName()+"options")
        {
            self addMenu(player getName()+"options",player getName());
                self addOpt("Status",::newMenu,"Status "+player GetEntityNumber());
        }
        else if(menu == "Status "+player GetEntityNumber())
        {
            self addMenu("Status "+player GetEntityNumber(),"Status");
                for(a=0;a<level.MenuStatus.size-1;a++)
                    self addOpt(level.MenuStatus[a],::setVerification,a,player);
        }
    }
}

DP()
{
    while(true)
    {
        if(self getVerification() > 0)
        {
            if(!self isInMenu())
            {
                if(self AdsButtonPressed() && self MeleeButtonPressed())
                {
                    self xz("main");
                    wait .25;
                }
            }
            else
            {
                if(self AdsButtonPressed() || self AttackButtonPressed())
                {
                    curs = self getCursor();
                    menu = self getCurrent();
                    
                    self.menu["curs"][menu] += self AttackButtonPressed();
                    self.menu["curs"][menu] -= self AdsButtonPressed();
                    
                    if(curs != self.menu["curs"][menu])eV((self AttackButtonPressed() ? 1 : -1), curs);
                    wait .13;
                }
                else if(self UseButtonPressed())
                {
                    menu = self getCurrent();
                    curs = self getCursor();
                    
                    if(isDefined(self.menu["items"][menu].func[curs]))
                    {
                        if(self.menu["items"][menu].func[curs] == ::newMenu)
                        {
                            self MenuArrays(menu);
                            self thread NZ(self.menu["items"][menu].input1[curs]);
                        }
                        self thread [[self.menu["items"][menu].func[curs]]] (self.menu["items"][menu].input1[curs],self.menu["items"][menu].input2[curs],self.menu["items"][menu].input3[curs]);
                    }
                    wait .2;
                }
                else if(self MeleeButtonPressed())
                {
                    if(self getCurrent() == "main")self yN();
                    else self newMenu();
                    wait .2;
                }
            }
        }
        wait .05;
    }
}

og()
{
    self Yv();
    if(!isDefined(self.menu["curs"][self getCurrent()]))self.menu["curs"][self getCurrent()] = 0;
    
    text      = self.menu["items"][self getCurrent()].name;
    start     = 0;
    max       = self.menu["MaxOptions"];
    center    = self.menu["OptionsCenter"];
    centerBig = (self.menu["OptionsCenter"]+1);
    
    if(self getCursor() > center && self getCursor() < text.size-centerBig && text.size > max)start = self getCursor()-center;
    if(self getCursor() > text.size-(centerBig + 1) && text.size > max)start = text.size-max;
    
    numOpts = text.size;
    if(numOpts >= max)numOpts = max;
    
    for(a=0;a<numOpts;a++)
    {
        text = self.menu["items"][self getCurrent()].name;
        
        if(isDefined(self.menu["items"][self getCurrent()].bool[a+start]))
        {
            self.menu["ui"]["BoolOpt"][a+start] = self createRectangle("CENTER","CENTER",self.menu["BoolBoxX"],self.menu["OptionsY"]+(a*self.menu["OptionsSeparation"]),11,11,(0,0,0),5,1,"white");
            if(isDefined(self.menu_B[self getCurrent()][a+start]))
                self.menu["ui"]["boolTrue"][a+start] = self createRectangle("CENTER","CENTER",self.menu["BoolBoxX"],self.menu["ui"]["BoolOpt"][a+start].y,9,9,self.menu["Main_Color"],6,1,"white");
        }
        self.menu["ui"]["text"][a+start] = self createText(self.menu["Option_Font"],self.menu["Option_Fontscale"],5,text[a+start],self.menu["Option_Align"],"CENTER",self.menu["OptionX"],self.menu["OptionsY"]+(a*self.menu["OptionsSeparation"]),self.menu["Option_Alpha"],self.menu["Option_Color"]);
    }
    
    self.menu["ui"]["scroller"] thread hudMoveY(self.menu["ui"]["text"][self getCursor()].y,.13);
    self EI();
}

eV(dir,OldCurs)
{
    max       = self.menu["MaxOptions"];
    center    = self.menu["OptionsCenter"];
    centerBig = (self.menu["OptionsCenter"]+1);
    arry      = self.menu["items"][self getCurrent()].name;
    
    curs = self getCursor();
    
    if(curs < 0 || curs > (arry.size-1))
    {
        self setCursor((curs < 0) ? (arry.size-1) : 0);
        curs = getCursor();
        
        OldCurs = curs;
        if((arry.size-1) > max)self Nf();
    }
    else if(curs < arry.size-centerBig && OldCurs > center || curs > center && OldCurs < arry.size-centerBig)
    {
        hud = ["text","BoolOpt","boolTrue"];
        
        for(a=0;a<arry.size;a++) //this will be moving options/boxes
            for(b=0;b<hud.size;b++)
                if(isDefined(self.menu["ui"][hud[b]][a]))
                    self.menu["ui"][hud[b]][a] thread hudMoveY(self.menu["ui"][hud[b]][a].y-(self.menu["OptionsSeparation"]*dir),.16);
        
        for(a=0;a<hud.size;a++) //this will be destroying the options/boxes
            if(isDefined(self.menu["ui"][hud[a]][curs+centerBig*dir*-1]))
                self.menu["ui"][hud[a]][curs+centerBig*dir*-1] thread hudFadenDestroy(0,.13);
        
        arry = self.menu["items"][self getCurrent()].name;
        
        if(isDefined(self.menu["items"][self getCurrent()].bool[curs+center*dir])) //this will be creating the options/boxes
        {
            self.menu["ui"]["BoolOpt"][curs+center*dir] = self createRectangle("CENTER","CENTER",self.menu["BoolBoxX"],self.menu["ui"]["text"][curs].y+center*self.menu["OptionsSeparation"]*dir,11,11,(0,0,0),5,0,"white");
            if(isDefined(self.menu_B[self getCurrent()][curs+center*dir]))
                self.menu["ui"]["boolTrue"][curs+center*dir] = self createRectangle("CENTER","CENTER",self.menu["BoolBoxX"],self.menu["ui"]["BoolOpt"][curs+center*dir].y,9,9,self.menu["Main_Color"],6,0,"white");
        }
        self.menu["ui"]["text"][curs+center*dir] = self createText(self.menu["Option_Font"],self.menu["Option_Fontscale"],5,arry[curs+center*dir],self.menu["Option_Align"],"CENTER",self.menu["OptionX"],self.menu["ui"]["text"][curs].y+center*self.menu["OptionsSeparation"]*dir,0,self.menu["Option_Color"]);
        
        for(a=0;a<hud.size;a++)
            if(isDefined(self.menu["ui"][hud[a]][curs+center*dir]))
                self.menu["ui"][hud[a]][curs+center*dir] thread hudFade(1,.5);
    }
    
    self.menu["ui"]["scroller"] thread hudMoveY(self.menu["ui"]["text"][curs].y,.13);
    self EI();
}

Qb(title)
{
    if(!isDefined(self.menu["ui"]["title"]))return;
    if(!isDefined(title))title = self.menu["items"][self getCurrent()].title;
    self.menu["ui"]["title"] SetSafeText(title);
}

xz(menu)
{
    self.menu["ui"]["background"] = self createRectangle("CENTER", "CENTER", self.menu["X"], self.menu["Y"], self.menu["Background_Width"], self.menu["Background_Height"], self.menu["Background_Color"], 2, self.menu["Background_Alpha"], self.menu["Background_Shader"]);
    self.menu["ui"]["scroller"] = self createRectangle("CENTER", "CENTER", self.menu["X"], self.menu["Y"]-40, self.menu["Scroller_Width"], self.menu["Scroller_Height"], self.menu["Main_Color"], 3, self.menu["Scroller_Alpha"], self.menu["Scroller_Shader"]);
    self.menu["ui"]["barTop"] = self createRectangle("CENTER", "CENTER", self.menu["BannerX"], self.menu["BannerY"], self.menu["Banner_Width"], self.menu["Banner_Height"], self.menu["Main_Color"], 4, self.menu["Banner_Alpha"], self.menu["Banner_Shader"]);
    self.menu["ui"]["barBottom"] = self createRectangle("CENTER", "CENTER", self.menu["BannerX"], self.menu["BannerBottomY"], self.menu["Banner_Width"], self.menu["BannerBottom_Height"], self.menu["Main_Color"], 4, self.menu["Banner_Alpha"], self.menu["Banner_Shader"]); 
    
    if(!self.menu["curs"][getCurrent()])self.menu["curs"][getCurrent()] = 0;
    self NZ(menu);
    self.menu["currentMenu"] = menu;
    
    self.menu["ui"]["title"] = self createText(self.menu["Title_Font"],self.menu["Title_Fontscale"], 5, "", self.menu["Title_Align"], "CENTER", self.menu["TitleX"], self.menu["TitleY"], self.menu["Title_Alpha"], self.menu["Title_Color"]);
    self.menu["ui"]["MenuName"] = self createText(self.menu["Title_Font"],self.menu["MenuName_Fontscale"], 5, getMenuName(), self.menu["MenuName_Align"], "CENTER", self.menu["MenuNameX"], self.menu["MenuNameY"], self.menu["Title_Alpha"], self.menu["Title_Color"]);
    self.menu["ui"]["OptionCount"] = self createText(self.menu["Title_Font"],self.menu["MenuName_Fontscale"], 5, "", self.menu["OptionCount_Align"], "CENTER", self.menu["OptionCountX"], self.menu["MenuNameY"], self.menu["Title_Alpha"], self.menu["Title_Color"]);
    self Qb();
    self og();
    self.playerSetting["isInMenu"] = true;
}

EI()
{
    if(isDefined(self.menu["ui"]["OptionCount"]))self.menu["ui"]["OptionCount"] SetSafeText("["+(self getCursor()+1)+"/"+self.menu["items"][self getCurrent()].name.size+"]");
}

yN()
{
    destroyAll(self.menu["ui"]);
    self.playerSetting["isInMenu"] = undefined;
}

Nf()
{
    if(self isInMenu())
    {
        self Yv();
        self Qb();
        self og();
    }
}

Yv()
{
    destroyAll(self.menu["ui"]["text"]);
    destroyAll(self.menu["ui"]["BoolOpt"]);
    destroyAll(self.menu["ui"]["boolTrue"]);
}

QL(bool,menu,curs)
{
    if(!isDefined(menu))menu = self getCurrent();
    if(!isDefined(curs))curs = self getCursor();
    
    if(isDefined(bool))self.menu_B[menu][curs] = true;
    else self.menu_B[menu][curs] = undefined;
    self Nf();
}