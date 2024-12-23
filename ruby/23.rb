require 'pp'
require 'set'

# ingest pairs to dict
@conns = File.open("../inputs/input23.txt", "r").each_line
.reduce(Hash.new { |hash, key| hash[key] = [] }){ |acc, str|
    a, b = str.strip.split('-')
    acc[a].push(b)
    acc[b].push(a)
    acc
}

# a member must start with t
@t_conns = @conns.select{ |k,v| k.start_with?('t') }

largest_clique_size = @t_conns.values.map{ |v| v.size }.max

# keys: sizes, 3 and up; values: sets of connected PCs
@groups = Hash.new{ |hash, key| hash[key] = Set.new() }

# P1: look for triangles: kh <-> qp <-> ub <-> kh
@t_conns
.each do |k1, list2|
    list2.each do |k2|
        list3 = @conns[k2]
        list3.each do |k3|
            list4 = @conns[k3]
            if [k1, k2].all? { |k| list4.include? k }
                @groups[3].add([k1, k2, k3].sort())
            end
        end
    end
end

p "P1: #{@groups[3].size}"


# P2: find largest clique of connected nodes

def grow_from_seed(clique = [])
    neighbs = clique.flat_map{ |k| @conns[k].to_a } - clique
    first_interconnected_nb = neighbs.find{ |nb| clique.all?{ |c| @conns[nb].include? c } }
    if !first_interconnected_nb
        clique
    else
        grow_from_seed(clique + [first_interconnected_nb])
    end
end

def to_graphviz(seed, allowed_keys)
    key_counts = Hash.new(0)
    lines = []
    @conns.select{ |k,v| allowed_keys.include? k }.each{ |k,v|
        lines << "#{k} -- {#{v.join( " ")}}"
        v.each{ |c| key_counts[c] += 1 }
    }

    # remove singularities
    lines_text = lines.join("\n")
    key_counts.each{ |k,count| lines_text.sub!(Regexp.new(k), '') if count < 2 }

    # write a file
    text = "strict graph {\n#{seed} [fontsize=\"30pt\"]\n" + lines_text + "}"
    File.open("#{seed}.dot", "w") { |file| file.write(text) }
end


@conns.keys.sort.each do |k|
    clique = grow_from_seed([k])
    if clique.size > 12
        p ["P2:", clique.size, clique.sort().join(",")]
        to_graphviz(k, clique)
        break;
    end
end

# P1: 1043
# P2: ai,bk,dc,dx,fo,gx,hk,kd,os,uz,xn,yk,zs
