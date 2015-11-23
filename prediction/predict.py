import csv
import datetime
from sklearn.linear_model import LogisticRegression, LinearRegression
from sklearn.svm import SVR
from numpy import *
from pylab import *
from sklearn.feature_selection import SelectKBest,chi2
import heapq
import itertools



def get_input(URL):
    with open(URL) as f_in:
        data = csv.reader(f_in)
        get_data = list()
        index = 0
        for row in data:
            if index == 0:
                get_data.append(row)
                index += 1
                continue
            temp = list()
            for k in row:
                temp.append(float(k))
            get_data.append(temp)

    feature = list()
    label = list()

    # print "get_data:",get_data
    for k in get_data[1:10]:
        temp = k[1:26]
        temp_label = k[26]
        feature.append(temp)
        label.append(temp_label)


    test_f = list()
    test_label = list()
    for k in get_data[10:]:
        test_f.append(k[1:26])
        test_label.append(k[26])

    test_f = asarray(test_f)
    test_label = asarray(test_label)

    feature = asarray(feature)
    label = asarray(label)
    return feature, label, test_f, test_label



if __name__ == '__main__':
    feature, label, test_f, test_label = get_input('totalTable.csv')

    print feature
    print feature.shape

    select_top_k_feature = SelectKBest(chi2,5)

    _top = list()
    for data in (select_top_k_feature.fit(feature,label).scores_):
        _top.append(data)
    print _top
    print heapq.nlargest(5,zip(_top,itertools.count()))
    print heapq.nlargest(5,range(len(_top)),key = _top.__getitem__)
