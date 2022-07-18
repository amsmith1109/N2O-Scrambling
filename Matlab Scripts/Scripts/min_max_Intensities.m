load NO
maxV31 = [];
minV31 = [];
maxV30 = [];
minV30 = [];
for i = 1:numel(names)
for j = 1:numel(NO.(names{i}))
data = NO.(names{i}){j};
I30 = [data.reference(:,1);data.sample(:,1)];
I31 = [data.reference(:,2);data.sample(:,2)];
maxV31(end+1) = max(I31);
minV31(end+1) = min(I31);
maxV30(end+1) = max(I30);
minV30(end+1) = min(I30);
end
end
disp(['Range 30: ',num2str(min(minV30)),' - ',num2str(max(maxV30))])
disp(['Range 31: ',num2str(min(minV31)),' - ',num2str(max(maxV31))])

load N2O
maxV46 = [];
minV46 = [];
maxV45 = [];
minV45 = [];
maxV44 = [];
minV44 = [];
for i = 1:numel(names)
for j = 1:numel(N2O.(names{i}))
data = N2O.(names{i}){j};
I44 = [data.reference(:,1);data.sample(:,1)];
I45 = [data.reference(:,2);data.sample(:,2)];
I46 = [data.reference(:,3);data.sample(:,3)];
maxV46(end+1) = max(I46);
minV46(end+1) = min(I46);
maxV45(end+1) = max(I45);
minV45(end+1) = min(I45);
maxV44(end+1) = max(I44);
minV44(end+1) = min(I44);
end
end
disp(['Range 44: ',num2str(min(minV44)),' - ',num2str(max(maxV44))])
disp(['Range 45: ',num2str(min(minV45)),' - ',num2str(max(maxV45))])
disp(['Range 46: ',num2str(min(minV46)),' - ',num2str(max(maxV46))])