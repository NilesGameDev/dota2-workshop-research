function move_elevator_up()
    print("Elevator start running...")
    if thisEntity == nil then
        print("Current entity is nil")
        return
    end
    thisEntity:SetVelocity(Vector(0, 0, 10))
end