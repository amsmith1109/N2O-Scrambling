clear all; close all;
load N2O
names = fields(N2O);
for i= 1:numel(names)
    set = N2O.(names{i});
    for j = 1:numel(set)
        Rtemp = set{j}.delta(1);
        dtemp = set{j}.delta(2);
        if dtemp < 30
            1;
        end
        R45{i}(j) = Rtemp(1);
        d46{i}(j) = dtemp(1);
    end
%     plot(R45{i},d46{i},'o')
    R45av(i) = mean(R45{i});
    d46av(i) = mean(d46{i});
    hold on
end
ft = polyfit(R45av,d46av,1);
plot(R45av,d46av,'o')
hold on
plot(R45av,polyval(ft,R45av))