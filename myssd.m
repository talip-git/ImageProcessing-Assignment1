function score = myssd(A,B)
    x = (A-B).^2;
    score = sum(x,"all")
end