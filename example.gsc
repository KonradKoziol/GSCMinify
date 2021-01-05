WidthEditor(type,int)
{
    allowWidth = undefined;
    if(type=="adjust")
    {
        if(int == 5 && self.menu["MenuWidth"] < 875 || int == -5 && self.menu["MenuWidth"] > 145)
        {
            allowWidth = true;
            self.menu["MenuWidth"] += int;
        }
        else self iPrintln("^1ERROR: ^7Menu Width Limit Reached");
    }
    else if(type=="custom")
    {
        allowWidth = true;
        self.menu["MenuWidth"] = int;
    }
    
    if(isDefined(allowWidth))
    {
        self.menu["HUDS"]["Background"] thread hudScaleOverTime(.2,self.menu["MenuWidth"],self.menu["height"]);
        self.menu["HUDS"]["Backgroundouter"] thread hudScaleOverTime(.2,self.menu["MenuWidth"] + 4,self.menu["height"]+5);
        self.menu["HUDS"]["Banner"] thread hudScaleOverTime(.2,self.menu["MenuWidth"],25);
        self.menu["HUDS"]["InfoBox"] thread hudScaleOverTime(.2,self.menu["MenuWidth"],25);
        self thread TitleAlign(self.menu["TitleAlign"]);
        self thread OptionsAlign(self.menu["OptionAlign"]);
        if(!isDefined(self.menu["AIOScroller"]))
        {
            self.menu["ScrollbarWidth"] = self.menu["MenuWidth"];
            self.menu["HUDS"]["Scroller"] thread hudScaleOverTime(.2,self.menu["MenuWidth"],self.menu["ScrollerHeight"]);
        }
        self iPrintln("Menu Width Set To ^2"+self.menu["MenuWidth"]);
        wait .5;
    }
}

setMenuColors(var,hud,color)
{
    self.menu[var] = color;
    if(var == "Select_Color")
    {
        self notify("SELECT_COLOR_CHANGED");
        return;
    }
    
    if(var == "Curs_Color")
    {
        if(isDefined(self.menu["Curs_Rainbow"]))self.menu["Curs_Rainbow"] = undefined;
        curs = self getCursor();
        self.menu["OPT"][curs] hudFadeColor(color,.2);
    }
    else if(var == "Opt_Color")
    {
        if(isDefined(self.menu["Options_Rainbow"]))self.menu["Options_Rainbow"] = undefined;
        for(a=0;a<self getOptions().size;a++)
            if(self.menu["OPT"][a] != self.menu["OPT"][self getCursor()])
                self.menu["OPT"][a] hudFadeColor(color,.2);
    }
    else
    {
        self.menu["HUDS"][hud] hudFadeColor(color,.2);
        if(hud == "Banners")
        {
            if(isDefined(self.menu["Banner_Rainbow"]))self.menu["Banner_Rainbow"] = undefined;
            huds = StrTok("Banner,InfoBox",",");
            for(a=0;a<huds.size;a++)self.menu["HUDS"][huds[a]] hudFadeColor(color,.2);
        }
        else if(hud == "Title")
        {
            if(isDefined(self.menu["MenuName_Rainbow"]))self.menu["MenuName_Rainbow"] = undefined;
            huds = StrTok("MenuName,InfoTxt",",");
            for(a=0;a<huds.size;a++)self.menu["HUDS"][huds[a]] hudFadeColor(color,.2);
        }
    }
    if(isDefined(self.menu[hud+"_Rainbow"]))self.menu[hud+"_Rainbow"] = undefined;
}

hudRainbow(hud)
{
    if(isDefined(self.menu[hud+"_Rainbow"]))return;
    self.menu[hud+"_Rainbow"] = true;
    
    self endon("disconnect");
    
    while(isDefined(self.menu[hud+"_Rainbow"]))
    {
        if(hud != "Options")
        {
            if(hud == "Banner")
            {
                self.menu["HUDS"]["Banner"] hudFadeColor(divideColor(RandomIntRange(0,255),RandomIntRange(0,255),RandomIntRange(0,255)),.5);
                self.menu["HUDS"]["InfoBox"] hudFadeColor(self.menu["HUDS"]["Banner"].color,.5);
            }
            else if(hud == "Curs")self.menu["OPT"][self getCursor()] hudFadeColor(divideColor(RandomIntRange(0,255),RandomIntRange(0,255),RandomIntRange(0,255)),.5);
            else if(hud == "MenuName")
            {
                self.menu["HUDS"]["MenuName"] hudFadeColor(divideColor(RandomIntRange(0,255),RandomIntRange(0,255),RandomIntRange(0,255)),.5);
                self.menu["HUDS"]["InfoTxt"] hudFadeColor(self.menu["HUDS"]["MenuName"].color,.5);
            }
            else self.menu["HUDS"][hud] hudFadeColor(divideColor(RandomIntRange(0,255),RandomIntRange(0,255),RandomIntRange(0,255)),.5);
        }
        else
            for(a=0;a<self getOptions().size;a++)
                if(self.menu["OPT"][a] != self.menu["OPT"][self getCursor()])
                    self.menu["OPT"][a] hudFadeColor(divideColor(RandomIntRange(0,255),RandomIntRange(0,255),RandomIntRange(0,255)),.5);
        wait .5;
    }
}

setMenuAlpha(var,hud,val)
{
    self.menu[var] = val;
    
    if(hud == "OPT")for(a=0;a<self getOptions().size;a++)self.menu["OPT"][a].alpha = val;
    else if(hud == "Title")
    {
        huds = StrTok("MenuName,InfoTxt",",");
        for(a=0;a<huds.size;a++)self.menu["HUDS"][huds[a]].alpha = val;
    }
    else if(hud == "Banner")
    {
        huds = StrTok("Banner,InfoBox",",");
        for(a=0;a<huds.size;a++)self.menu["HUDS"][huds[a]].alpha = val;
    }
    else self.menu["HUDS"][hud].alpha = val;
}

ChangeShader(shader,hud,var,width,height)
{
    self.menu[var] = shader;
    self.menu["HUDS"][hud] SetShader(shader,width,height);
}

changefont(type,font)
{
    if(type == "Opt")
    {
        self.menu["OptionFont"] = font;
        for(a=0;a<self getOptions().size;a++)self.menu["OPT"][a].font = font;
    }
    if(type == "Title")
    {
        self.menu["TitleFont"] = font;
        huds = StrTok("InfoTxt,MenuName",",");
        for(a=0;a<huds.size;a++)self.menu["HUDS"][huds[a]].font = font;
    }
}

TitleStatusFontScale(scale)
{
    self.menu["TitleFontScale"] = scale;
    
    huds = StrTok("InfoTxt,MenuName",",");
    for(a=0;a<huds.size;a++)self.menu["HUDS"][huds[a]] ChangeFontscaleOverTime1(scale,.1);
}

OptionFontScale(scale)
{
    self.menu["OptionFontscale"]=scale;
    for(a=0;a<self getOptions().size;a++)self.menu["OPT"][a] ChangeFontScaleOverTime1(scale,.1);
}

TitleAlign(align)
{
    if(align == "LEFT")self.menu["TitleX"] = self.menu["X"]+5;
    if(align == "CENTER")self.menu["TitleX"] = self.menu["X"]+(self.menu["MenuWidth"]/2);
    if(align == "RIGHT")self.menu["TitleX"] = self.menu["X"]+self.menu["MenuWidth"]-5;
    
    self.menu["TitleAlign"] = align;
    self refreshTitle();
}

OptionsAlign(align)
{
    if(align == "LEFT")self.menu["OptionsX"] = self.menu["X"]+5;
    if(align == "CENTER")self.menu["OptionsX"] = self.menu["X"]+(self.menu["MenuWidth"]/2);
    if(align == "RIGHT")self.menu["OptionsX"] = self.menu["X"]+self.menu["MenuWidth"]-5;
    
    self.menu["OptionAlign"] = align;
    self refreshMenu();
}

LargeCursor()
{
    self.menu["LargeCursor"] = (isDefined(self.menu["LargeCursor"]) ? undefined : true);
    self SetColor(self.menu["LargeCursor"]);
    self refreshMenu();
}

sortAnimation()
{
    self.menu["sortAnimation"] = (isDefined(self.menu["sortAnimation"]) ? undefined: true);
    self.menu["animationSort"] = (isDefined(self.menu["sortAnimation"]) ? 7 : 10);
    
    self SetColor(self.menu["sortAnimation"]);
    self refreshMenu();
}

quickMenu()
{
    self.menu["InstantOpen"] = (isDefined(self.menu["InstantOpen"]) ? undefined : true);
    self SetColor(self.menu["InstantOpen"]);
}

ScrollerAIOStyle()
{
    self.menu["AIOScroller"] = (isDefined(self.menu["AIOScroller"]) ? undefined : true);
    self.menu["ScrollbarWidth"] = (isDefined(self.menu["AIOScroller"]) ? 2 : self.menu["MenuWidth"]);
    self.menu["ScrollerHeight"] = (isDefined(self.menu["AIOScroller"]) ? 28 : 18);
    
    self.menu["HUDS"]["Scroller"] hudScaleOverTime(.2,self.menu["ScrollbarWidth"],self.menu["ScrollerHeight"]);
    self SetColor(self.menu["AIOScroller"]);
}

DisableInstructions()
{
    self.menu["DisableInstructions"] = (isDefined(self.menu["DisableInstructions"]) ? undefined : true);
    self SetColor(self.menu["DisableInstructions"]);
    self UpdateInstructions();
}

DisableEntityCount()
{
    self.menu["DisableEntityCount"] = (isDefined(self.menu["DisableEntityCount"]) ? undefined : true);
    self SetColor(self.menu["DisableEntityCount"]);
}

CursorAnimation()
{
    self.menu["CursorAnimation"] = (isDefined(self.menu["CursorAnimation"]) ? undefined : true);
    self SetColor(self.menu["CursorAnimation"]);
    self refreshMenu();
}

SetTextAnimation(player)
{
    if(isDefined(self.TextAnim))return;
    self endon(self+"_endAnim");
    
    self.TextAnim = true;
    
    while(isDefined(self) && isDefined(self.TextAnim))
    {
        self thread hudFade(.3,.5);
        wait .5;
        self thread hudFade(player.menu["OptionAlpha"],.5);
        wait .5;
    }
}

CursAnimCheck(curs)
{
    if(isDefined(self.menu["CursorAnimation"]))self.menu["OPT"][curs] thread SetTextAnimation(self);
    self.menu["OPT"][curs].sort = 12;
    if(isDefined(self.menu["LargeCursor"]))self.menu["OPT"][curs] ChangeFontscaleOverTime1(self.menu["OptionFontscale"]+.4,.1);
}

OptionsDisableAnim(a)
{
    self.menu["OPT"][a].sort = self.menu["animationSort"];
    self.menu["OPT"][a].fontScale = self.menu["OptionFontscale"];
    self.menu["OPT"][a] notify(self.menu["OPT"][a]+"_endAnim");
    self.menu["OPT"][a].TextAnim = undefined;
    self.menu["OPT"][a] thread hudFade(self.menu["OptionAlpha"],0);
}

MaxOptions(max)
{
    max = int(max);
    
    switch(max)
    {
        case 5:
            self.menu["height"]  = 183;
            self.menu["heightY"] = 79;
            break;
        case 7:
            self.menu["height"]  = 225;
            self.menu["heightY"] = 100;
            break;
        case 9:
            self.menu["height"]  = 274;
            self.menu["heightY"] = 125;
            break;
        case 11:
            self.menu["height"]  = 322;
            self.menu["heightY"] = 149;
            break;
        case 13:
            self.menu["height"]  = 365;
            self.menu["heightY"] = 170;
            break;
    }
    
    self.menu["MaxOptions"] = max;
    self.menu["OptionsCenter"] = int((max/2));
    
    self.menu["HUDS"]["Background"] thread hudScaleOverTime(.15,self.menu["MenuWidth"],self.menu["height"]);
    self.menu["HUDS"]["Backgroundouter"] thread hudScaleOverTime(.15,self.menu["MenuWidth"] + 4,(self.menu["height"]+5));
    self.menu["HUDS"]["Banner"] thread hudMoveY((self.menu["Y"]+self.menu["heightY"]),.15);
    self.menu["HUDS"]["InfoBox"] thread hudMoveY((self.menu["Y"]-self.menu["heightY"]),.15);
    self.menu["HUDS"]["InfoTxt"] thread hudMoveY((self.menu["Y"]+self.menu["heightY"]),.15);
    self.menu["HUDS"]["MenuName"] hudMoveY((self.menu["Y"]-self.menu["heightY"]),.15);
    
    self refreshMenu();
}

MoveMenu(amount,direction)
{
    huds = StrTok("Backgroundouter,Background,Banner,MenuName,InfoBox,InfoTxt,Title,Scroller",",");
    
    switch(direction)
    {
        case "Y":
            for(a=0;a<huds.size;a++)self.menu["HUDS"][huds[a]] thread hudMoveY(int(amount)+self.menu["HUDS"][huds[a]].y,.01);
            for(a=0;a<self getOptions().size;a++)self.menu["OPT"][a] hudMoveY(int(amount)+self.menu["OPT"][a].y,.01);
            self.menu["Y"] += int(amount);
            break;
        case "X":
            for(a=0;a<huds.size;a++)self.menu["HUDS"][huds[a]] thread hudMoveX(int(amount)+self.menu["HUDS"][huds[a]].x,.01);
            for(a=0;a<self getOptions().size;a++)self.menu["OPT"][a] thread hudMoveX(int(amount)+self.menu["OPT"][a].x,.01);
            
            self.menu["X"] += int(amount);
            self thread TitleAlign(self.menu["TitleAlign"]);
            self thread OptionsAlign(self.menu["OptionAlign"]);
            break;
    }
}

PositionEditor()
{
    if(isDefined(self.PositionEditor))return;
    self.PositionEditor = true;
    
    self endon("disconnect");
    self endon("endPosEditor");
    
    self newMenu("Control Position Editor");
    self thread setInstructions("[{+speed_throw}]: Move Menu Left ^2-- ^7[{+attack}]: Move Menu Right ^2-- ^7[{+frag}]: Move Menu Up ^2-- ^7[{+smoke}]: Move Menu Down ^2-- ^7[{+melee}]: Exit Position Editor");
    wait .3;
    
    while(isDefined(self.PositionEditor))
    {
        if(self AdsButtonPressed())self MoveMenu(-10,"X");
        else if(self AttackButtonPressed())self MoveMenu(10,"X");
        else if(self FragButtonPressed())self MoveMenu(-10,"Y");
        else if(self SecondaryOffhandButtonPressed())self MoveMenu(10,"Y");
        else if(self MeleeButtonPressed())break;
        wait .05;
    }
    
    wait .05;
    self.PositionEditor = undefined;
    self thread HideInstructions();
}

ResetMenuPosition()
{
    huds = StrTok("Background,Scroller",",");
    self.menu["X"] = -64;
    self.menu["Y"] = 0;
    
    for(a=0;a<huds.size;a++)self.menu["HUDS"][huds[a]] thread hudMoveXY(0,self.menu["X"],self.menu["Y"]);
    self thread TitleAlign(self.menu["TitleAlign"]);
    self thread OptionsAlign(self.menu["OptionAlign"]);
    
    self.menu["HUDS"]["Backgroundouter"] thread hudMoveXY(0,self.menu["X"]-2,self.menu["Y"]);
    self.menu["HUDS"]["Banner"] thread hudMoveXY(0,self.menu["X"],100);
    self.menu["HUDS"]["InfoBox"] thread hudMoveXY(0,self.menu["X"],-100);
    self.menu["HUDS"]["InfoTxt"] thread hudMoveXY(0,self.menu["TitleX"],100);
    self.menu["HUDS"]["MenuName"] hudMoveXY(0,self.menu["TitleX"],-100);
    self revalueScrolling(self.menu["X"]);
}

ResetMenuDesign()
{
    vars = StrTok("Scroller,Curs,Options,Background,Backgroundouter,Banner,MenuName",",");
    for(a=0;a<vars.size;a++)if(isDefined(self.menu[vars[a]+"_Rainbow"]))self.menu[vars[a]+"_Rainbow"]=undefined;
    
    menuVars    = ["Select_Color","Banners_Color","Scroller_Color","Curs_Color","BgOuter_Color","Bg_Color","Opt_Color","Title_Color","Y","MenuWidth","animationSort","ScrollerHeight","ScrollbarWidth","MaxOptions","OptionsCenter","MenuSeperation","BackgroundouterAlpha","BackgroundAlpha","BannerAlpha","ScrollerAlpha","TitleAlpha","OptionAlpha","BackgroundouterShader","BackgroundShader","BannerShader","ScrollerShader","OptionFont","TitleFont","OptionFontscale","TitleFontScale","OptionAlign","TitleAlign"];
    menuVarsVal = [divideColor(140,255,115),divideColor(0,110,255),divideColor(0,110,255),divideColor(255,255,255),divideColor(0,0,0),divideColor(0,0,0),divideColor(255,255,255),divideColor(255,255,255),0,160,7,28,2,7,3,23,.5,.7,1,1,1,1,"white","white","white","white","default","default",1.1,1.4,"LEFT","LEFT"];
    for(a=0;a<menuVars.size;a++)self.menu[menuVars[a]] = menuVarsVal[a];
    self.menu["X"] = -45;
    self.menu["TitleX"] = self.menu["X"]+5;
    self.menu["OptionsX"] = self.menu["X"]+5;
    self.menu["height"] = 225;
    self.menu["heightY"] = 100;
    
    trueVars = StrTok("AIOScroller,sortAnimation",",");
    for(a=0;a<trueVars.size;a++)self.menu[trueVars[a]] = true;
    undefinedvars = StrTok("InstantOpen,LargeCursor,CursorAnimation,DisableInstructions,DisableEntityCount",",");
    for(a=0;a<undefinedvars.size;a++)self.menu[undefinedvars[a]] = undefined;
    
    vars = StrTok("LargeCursor,sortAnimation,InstantOpen,AIOScroller",",");
    for(a=0;a<vars.size;a++)self SetColor(self.menu[vars[a]],"Menu Customization",(a+6));
    
    vars = StrTok("DisableInstructions,DisableEntityCount,CursorAnimation",",");
    for(a=0;a<vars.size;a++)self SetColor(self.menu[vars[a]],"Menu Customization",(a+11));
    
    if(self isInMenu())self ForceCloseMenu();
    self iPrintln("Menu Design ^2Reset");
}

LoadSavedDesign(display)
{
    if(self GetSavedVariable("MenuDesignSaved") == "1")
    {
        if(self isInMenu())self ForceCloseMenu();
        
        vars = StrTok("Scroller,Curs,Options,Background,Backgroundouter,Banner,MenuName",",");
        for(a=0;a<vars.size;a++)if(self GetSavedVariable(vars[a]+"_Rainbow")=="1")self thread hudRainbow(vars[a]);
        menuvars = StrTok("Select_Color,Banners_Color,Scroller_Color,Curs_Color,BgOuter_Color,Bg_Color,Opt_Color,Title_Color",",");
        for(a=0;a<menuvars.size;a++)self.menu[menuvars[a]]=self GetSavedVariable(menuvars[a],true);
        vars = ["MenuWidth","ScrollbarWidth","ScrollerHeight","OptionFontscale","TitleFontScale","X","Y","BackgroundAlpha","BackgroundouterAlpha","BannerAlpha","ScrollerAlpha","TitleAlpha","OptionAlpha","MaxOptions","OptionsCenter","MenuSeperation","height","heightY"];
        for(a=0;a<vars.size;a++)self.menu[vars[a]]=intfloat(self GetSavedVariable(vars[a]));
        
        vars = StrTok("InstantOpen,LargeCursor,CursorAnimation,DisableInstructions,DisableEntityCount,sortAnimation,AIOScroller",",");
        for(a=0;a<vars.size;a++)
        {
            if(self GetSavedVariable(vars[a]) == "1")
            {
                self.menu[vars[a]] = true;
                
                if(vars[a] == "sortAnimation")self.menu["animationSort"] = 7;
                if(vars[a] == "AIOScroller")
                {
                    self.menu["ScrollerHeight"] = 25;
                    self.menu["ScrollbarWidth"] = 2;
                }
            }
            else
            {
                self.menu[vars[a]] = undefined;
                
                if(vars[a] == "sortAnimation")self.menu["animationSort"] = 10;
                if(vars[a] == "AIOScroller")
                {
                    self.menu["ScrollerHeight"] = 18;
                    self.menu["ScrollbarWidth"] = self.menu["MenuWidth"];
                }
            }
        }
        
        vars = StrTok("LargeCursor,sortAnimation,InstantOpen,AIOScroller",",");
        for(a=0;a<vars.size;a++)self SetColor(self.menu[vars[a]],"Menu Customization",(a+6));
        vars = StrTok("DisableInstructions,DisableEntityCount,CursorAnimation",",");
        for(a=0;a<vars.size;a++)self SetColor(self.menu[vars[a]],"Menu Customization",(a+11));
        
        vars = StrTok("BackgroundouterShader,BackgroundShader,BannerShader,ScrollerShader,OptionFont,TitleFont",",");
        for(a=0;a<vars.size;a++)self.menu[vars[a]]=self GetSavedVariable(vars[a]);
        
        varsalign = StrTok("TitleAlign,OptionAlign",",");
        for(a=0;a<varsalign.size;a++)
        {
            dvarsval = self GetSavedVariable(varsalign[a]);
            if(dvarsval != "")self.menu[varsalign[a]] = dvarsval;
        }
        self TitleAlign(self.menu["TitleAlign"]);
        self OptionsAlign(self.menu["OptionAlign"]);
        
        if(isDefined(display))self iPrintln("Saved Design ^2Loaded");
    }
    else if(isDefined(display))self iPrintln("^1ERROR: ^7No Saved Design Found");
}

SaveMenuDesign()
{
    if(self isHost() && !isConsole())self refreshPermSave();
    
    self SetSavedVariable("MenuDesignSaved","1");
    
    vars = StrTok("Scroller,Curs,Options,Background,Backgroundouter,Banner,MenuName",",");
    for(a=0;a<vars.size;a++)self SetSavedVariable(vars[a]+"_Rainbow",(isDefined(self.menu[vars[a]+"_Rainbow"]) ? "1" : ""));
    dvars = StrTok("InstantOpen,AIOScroller,LargeCursor,CursorAnimation,sortAnimation,DisableInstructions,DisableEntityCount",",");
    for(a=0;a<dvars.size;a++)self SetSavedVariable(dvars[a],(isDefined(self.menu[dvars[a]]) ? "1" : ""));
    vars = ["MaxOptions","OptionsCenter","MenuSeperation","Bg_Color","BgOuter_Color","Banners_Color","Scroller_Color","Curs_Color","Title_Color","Opt_Color","Select_Color","BackgroundShader","BackgroundouterShader","ScrollerShader","BannerShader","BackgroundAlpha","BackgroundouterAlpha","BannerAlpha","ScrollerAlpha","TitleAlpha","OptionAlpha","OptionFont","TitleFont","OptionFontscale","TitleFontScale","OptionAlign","TitleAlign","X","Y","MenuWidth","ScrollbarWidth","ScrollerHeight","height","heightY"];
    for(a=0;a<vars.size;a++)self SetSavedVariable(vars[a],self.menu[vars[a]]);
    
    self iPrintln("Menu Design ^2Saved");
}

refreshPermSave()
{
    SetDvar("server9","");
}

SetSavedVariable(var,value)
{
    if(self isHost() && !isConsole())
    {
        dvar = GetDvar("server9");
        dvar += var+"="+value+";";
        SetDvar("server9",dvar);
    }
    else SetDvar(self GetXUID()+var,value);
}

GetSavedVariable(var,vec)
{
    if(self isHost() && !isConsole())
    {
        saveToks = StrTok(GetDvar("server9"),";");
        if(!IsSubStr(saveToks[0],"MenuDesignSaved"))return "0";
        
        for(a=0;a<saveToks.size;a++)
        {
            value = StrTok(saveToks[a],"=");
            if(value[0] == var)
            {
                if(value.size > 1)savedVar = value[1];
                else savedVar = "";
            }
        }
        
        if(savedVar != "" && isDefined(vec))
        {
            SetDvar(self GetXUID()+var,savedVar);
            savedVar = GetDvarVector(self GetXUID()+var);
        }
        
        return savedVar;
    }
    
    if(isDefined(vec))return GetDvarVector(self GetXUID()+var);
    return GetDvar(self GetXUID()+var);
}