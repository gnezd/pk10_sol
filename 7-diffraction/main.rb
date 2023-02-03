#!/usr/bin/ruby
def phase(r, k)
  [Math.cos(k.to_f*r.to_f), Math.sin(k.to_f*r.to_f)]
end

h_n_w = 200
scale = 80
screen_x = (0..h_n_w-1).map {|i| (i-h_n_w/2).to_f/h_n_w*scale}
screen_r = Array.new(h_n_w) {Array.new(h_n_w) {0.0}}
screen_i = Array.new(h_n_w) {Array.new(h_n_w) {0.0}}
screen = Array.new(h_n_w) {Array.new(h_n_w) {0.0}}
l = 2000.0 # Distance to screen

k = (1/630E-6)*2*3.1415
smpl_rate = 50

puts Time.now
light_points = []
light_pt_smpl = 50
apper_radius = 0.1
(0..light_pt_smpl).each do |x|
  (0..light_pt_smpl).each do |y|
    light_points.push [(x-light_pt_smpl/2).to_f/light_pt_smpl*apper_radius, (y-light_pt_smpl/2).to_f/light_pt_smpl*apper_radius] if ((x-light_pt_smpl/2))**2 + ((y-light_pt_smpl/2))**2 < (light_pt_smpl**2)/4
  end
end
# Construct light source
light_points.each do |light|
  dx, dy = light
  screen_x.each_with_index do |x, i|
    screen_x.each_with_index do |y, yi|
      d = (l**2 + (x.to_f-dx)**2 + (y.to_f-dy)**2)**0.5
      ph = phase(d, k)
      screen_r[yi][i] += ph[0]
      screen_i[yi][i] += ph[1]
    end
  end
end
puts Time.now

fout = File.open('out-2d-r.txt', 'w')
screen_r.each do |ln|
  fout.puts ln.join ' '
end
fout.close

fout = File.open('out-2d-i.txt', 'w')
screen_i.each do |ln|
  fout.puts ln.join ' '
end
fout.close

(0..h_n_w-1).each do |xi|
  (0..h_n_w-1).each do |yi|
    screen[xi][yi] = (screen_i[xi][yi]**2 + screen_r[xi][yi]**2)**0.5
  end
end

fout = File.open('out-2d.txt', 'w')
screen.each do |ln|
  fout.puts ln.join ' '
end
fout.close