include("autorun/tbc_weapon_metatable.lua")  

SWEP.PrintName = "Titanomachia"
SWEP.Author = "Nara" 
SWEP.Contact = ""
SWEP.Purpose = "	A spiritual gun imbued with the magic of Hecatonchires."
SWEP.Instructions = ""
SWEP.Category = "SMT Imagine"

SWEP.Spawnable = true
SWEP.AdminOnly = false

local ShootSound = Sound("Weapon_Pistol.Single")
SWEP.Primary.Damage = 9
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 12
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.DefaultClip = 18
SWEP.Primary.Spread = 0.1
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = .2
SWEP.Primary.Delay = 1
SWEP.Primary.Force = 100

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false


SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 60
SWEP.ViewModel			= "models/weapons/smti_handgun2_v.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"
SWEP.UseHands           = true



SWEP.HoldType = "Pistol" 


SWEP.FiresUnderwater = false



SWEP.ReloadSound = Sound("Weapon_Pistol.Reload")



SWEP.CSMuzzleFlashes = true

function SWEP:Initialize()
util.PrecacheSound(ShootSound) 
util.PrecacheSound(self.ReloadSound) 
self:SetWeaponHoldType( self.HoldType )
end 

function SWEP:PrimaryAttack()
 
if ( !self:CanPrimaryAttack() ) then return end
 
local bullet = {} 
bullet.Num = self.Primary.NumberofShots 
bullet.Src = self.Owner:GetShootPos() 
bullet.Dir = self.Owner:GetAimVector() 
bullet.Spread = Vector( self.Primary.Spread * 0.1 , self.Primary.Spread * 0.1, 0)
bullet.Tracer = 1
bullet.Force = self.Primary.Force 
bullet.Damage = self.Primary.Damage 
bullet.AmmoType = self.Primary.Ammo 
 
local rnda = self.Primary.Recoil * -1 
local rndb = self.Primary.Recoil * math.random(-1, 1) 
 
self:ShootEffects()
 
self.Owner:FireBullets( bullet ) 
self:EmitSound(ShootSound)
self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) ) 
self:TakePrimaryAmmo(self.Primary.TakeAmmo) 
 
self:SetNextPrimaryFire( CurTime() + self.Primary.Delay ) 
end 

function SWEP:SecondaryAttack()

end

function SWEP:Reload()
self:EmitSound(Sound(self.ReloadSound)) 
        self.Weapon:DefaultReload( ACT_VM_RELOAD );
end