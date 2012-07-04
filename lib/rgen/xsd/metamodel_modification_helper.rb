module RGen

module XSD

module MetamodelModificationHelper

def find_feature(env, desc)
  env.find(:class => RGen::ECore::EStructuralFeature, :name => desc.split("#").last).
    find{|f| f.eContainingClass.name == desc.split("#").first}
end

def attribute_to_reference(env, desc, target)
  a = find_feature(env, desc)
  r = env.new(RGen::ECore::EReference, Hash[
    RGen::ECore::EStructuralFeature.ecore.eAllStructuralFeatures.collect do |f| 
      next if f.derived
      p = [f.name, a.getGeneric(f.name)]
      if f.many
        a.setGeneric(f.name, [])
      else
        a.setGeneric(f.name, nil)
      end
      p
    end])
  r.eType = target
  r
end

def create_opposite(env, desc, name, upper_bound)
  r = find_feature(env, desc)
  r.eOpposite = 
    env.new(RGen::ECore::EReference, :name => name, :eType => r.eContainingClass, 
      :eContainingClass => r.eType, :upperBound => upper_bound, :eOpposite => r)
end

end

end

end

