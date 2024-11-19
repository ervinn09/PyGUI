function mosACR = ec2acr(mosEC)
mosEC = (mosEC - 10)/10;
% mosACR = mosEC;

mosACR = -0.0262*mosEC.^3 + 0.2368*mosEC.^2 + 0.1907*mosEC + 1;

mosACR(mosACR<1) = 1;
mosACR(mosACR>5) = 5;

end