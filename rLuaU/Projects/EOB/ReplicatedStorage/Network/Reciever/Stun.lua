return {
    Dependencies = {
        "CharacterStates";
    };
    Run = function(Dependencies, Length)
       Dependencies.CharacterStates:AddState("Stun", Length)
    end
}