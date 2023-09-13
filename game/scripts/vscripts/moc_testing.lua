function ChangeAlpha()
    print("MOC test current entity index: " .. thisEntity:GetEntityIndex())
    print("MOC test current entity index: " .. thisEntity:entindex())
    thisEntity:SetRenderAlpha(15)
end