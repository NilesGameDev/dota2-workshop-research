local function DefaultComparator(itemA, itemB)
    if itemA > itemB then
        return 1
    elseif itemA == itemB then
        return 0
    end

    return -1
end

if StandardHeap == nil then
    StandardHeap = class({
        heap = {},
        itemCount = 0,
        compare = DefaultComparator,

        constructor = function(self, comparator)
            self.compare = comparator or self.compare
        end
    })
end

function StandardHeap:Add(item)
    item.heapIndex = self.itemCount
    self.heap[self.itemCount] = item
    self:_SortUp(item)
    self.itemCount = self.itemCount + 1
end

function StandardHeap:RemoveFirst()
    local firstItem = self.heap[0]
    self.itemCount = self.itemCount - 1
    self.heap[0] = self.heap[self.itemCount]
    self.heap[0].heapIndex = 0
    self:_SortDown(self.heap[0])

    return firstItem
end

function StandardHeap:UpdateItem(item)
    self:_SortUp(item)
end

function StandardHeap:Contains(item, equalFunc)
    return equalFunc(self.heap[item.heapIndex], item)
end

function StandardHeap:_SortUp(item)
    local parentIndex = math.floor((item.heapIndex - 1) / 2)
    if parentIndex == -1 then
        return
    end

    while true do
        local parentItem = self.heap[parentIndex]
        if parentItem == nil then
            break
        end

        if self.compare(item, parentItem) > 0 then
            self:_Swap(item, parentItem)
        else
            break
        end

        parentIndex = math.floor((item.heapIndex - 1) / 2)
    end
end

function StandardHeap:_SortDown(item)
    while true do
        local leftChildIndex = 2 * item.heapIndex + 1
        local rightChildIndex = 2 * item.heapIndex + 2
        local swapIndex = 0

        if leftChildIndex < self.itemCount then
            swapIndex = leftChildIndex

            if rightChildIndex < self.itemCount then
                if self.compare(self.heap[leftChildIndex], self.heap[rightChildIndex]) < 0 then
                    swapIndex = rightChildIndex
                end
            end

            if self.compare(item, self.heap[swapIndex]) < 0 then
                self:_Swap(item, self.heap[swapIndex])
            else
                return
            end
        else
            return
        end
    end
end

function StandardHeap:_Swap(itemA, itemB)
    self.heap[itemA.heapIndex] = itemB
    self.heap[itemB.heapIndex] = itemA

    local temp = itemA.heapIndex
    itemA.heapIndex = itemB.heapIndex
    itemB.heapIndex = temp
end
