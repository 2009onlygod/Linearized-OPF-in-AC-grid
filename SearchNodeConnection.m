function SearchofIJ=SearchNodeConnection(I,J,PvI)
SortofIJ=[I,J;J,I];      %��·���ӹ�ϵ
SearchofIJ=[];
for i=1:length(PvI)  %�����ͷ�����ڵ����ӵ���·���
    SearchofIJ=[SearchofIJ;SortofIJ(SortofIJ(:,1)==PvI(i),:)];    
end
SearchofIJ=unique(SearchofIJ,'rows');
end