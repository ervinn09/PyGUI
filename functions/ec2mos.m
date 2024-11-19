function mos = ec2mos(ec)

mos = 1 + 0.1907*ec + 0.2368*ec.^2 - 0.0262*ec.^3;

end