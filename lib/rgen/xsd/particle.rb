module Particle

# helper structure representing a particle or particle tree
# particles of kind :choice, :sequence or :all can have child particles
Particle = Struct.new(:kind, :children, :minOccurs, :maxOccurs, :node)

# builds a flat list of the element particles contained in +node+
# to be used for ComplexType and complex content extensions 
def element_particles(node)
  trees = build_particles_trees(node)
  if trees.size == 1
    flatten_particle_tree(trees.first)
  elsif trees.size > 1
    puts "WARN: only one particle expected as a content model"
    []
  else
    []
  end
end

def add_substitution_particles(particles)
  result = []
  particles.each do |p|
    result << p
    if p.kind == :element
      p.node.substitutes.each do |s|
        result << Particle.new(:element, [], p.minOccurs, p.maxOccurs, s)
      end
    end
  end
  result
end

# flattens the particle tree with root +particle+ and calculates min/max occurrence
# returns a list of particles of kind "element" and "any"
# element names are unique throughout the list
# the order is the order of first occurrence
def flatten_particle_tree(particle)
  if particle.kind == :element || particle.kind == :any
    [particle]
  else 
    eocc = {}
    elist = []
    particle.children.each do |c|
      flatten_particle_tree(c).each do |e|
        if e.kind == :element
          name = e.node.name
        else
          name = "#any#" 
        end
        if !eocc[name]
          eocc[name] = [] 
          elist << name
        end
        eocc[name] << e
      end
    end
    is_unbounded = lambda do |particle, elements|
      (particle.maxOccurs == "unbounded" && 
        elements.any?{|e| e.maxOccurs == "unbounded" || e.maxOccurs.to_i > 0}) ||
        (particle.maxOccurs.to_i > 0 &&
        elements.any?{|e| e.maxOccurs == "unbounded"})
    end
    if particle.kind == :choice
      elist.collect do |n|
        if eocc[n].size < particle.children.size
          # element is not in every choice
          min = 0
        else
          min = eocc[n].collect{|e| e.minOccurs.to_i}.min * particle.minOccurs.to_i
        end
        if is_unbounded.call(particle, eocc[n])
          max = "unbounded"
        else
          max = eocc[n].collect{|e| e.maxOccurs.to_i}.max * particle.maxOccurs.to_i
        end
        if n == "#any#"
          Particle.new(:any, [], min, max, eocc[n].first.node)
        else
          Particle.new(:element, [], min, max, eocc[n].first.node)
        end
      end
    else # sequence or all
      elist.collect do |n|
        min = eocc[n].inject(0){|m, e| m + e.minOccurs.to_i} * particle.minOccurs.to_i
        if is_unbounded.call(particle, eocc[n])
          max = "unbounded"
        else
          max = eocc[n].inject(0){|m, e| m + e.maxOccurs.to_i} * particle.maxOccurs.to_i
        end
        if n == "#any#"
          Particle.new(:any, [], min, max, eocc[n].first.node)
        else
          Particle.new(:element, [], min, max, eocc[n].first.node)
        end
      end
    end
  end
end

# builds the particle trees for the particles contained in node
def build_particles_trees(node)
  trees = []
  # ComplexType and extension type have only one choice, sequence, all, group
  choices = node.choice
  choices = [choices].compact unless choices.is_a?(Array)
  choices.each do |c|
    trees << Particle.new(:choice, build_particles_trees(c), c.minOccurs || "1", c.maxOccurs || "1", c)
  end
  sequences = node.sequence
  sequences = [sequences].compact unless sequences.is_a?(Array)
  sequences.each do |s|
    trees << Particle.new(:sequence, build_particles_trees(s), s.minOccurs || "1", s.maxOccurs || "1", s)
  end
  alls = node.all
  alls = [alls].compact unless alls.is_a?(Array)
  alls.each do |a|
    trees << Particle.new(:all, build_particles_trees(s), a.minOccurs || "1", a.maxOccurs || "1", a)
  end
  # Group definitions don't have group reference particles
  if node.respond_to?(:group)
    groups = node.group
    groups = [groups].compact unless groups.is_a?(Array)
    groups.each do |g|
      if g.ref
        # the referenced group is a Model Group Definition, i.e. a node wrapping a Model Group
        # it must contain at most one of Choice, Sequence, All
        # it must not contain another "group" tag because this would be a particle
        group_childs = g.ref.all + g.ref.choice + g.ref.sequence
        if group_childs.size == 1
          gtc = build_particles_trees(g.ref).first
          gtc.minOccurs = g.minOccurs || "1"
          gtc.maxOccurs = g.maxOccurs || "1"
          trees << gtc
        elsif group_childs.size > 1
          puts "WARN: ignoring model group definition containing more than one model group"
        else
          # empty, ignore
        end
      else
        puts "WARN: ignoring non-toplevel group without a ref"
      end
    end
  end
  # ComplexType and complex content extension don't have element particles
  if node.respond_to?(:element)
    node.element.each do |e|
      if e.ref
        trees << Particle.new(:element, [], e.minOccurs || "1", e.maxOccurs || "1", e.ref)
      else
        trees << Particle.new(:element, [], e.minOccurs || "1", e.maxOccurs || "1", e)
      end
    end
  end
  # ComplexType and complex content extension don't have 'any' particles
  if node.respond_to?(:any)
    node.any.each do |a|
      trees << Particle.new(:any, [], a.minOccurs || "1", a.maxOccurs || "1", a)
    end
  end
  trees
end

end

