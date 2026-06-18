package com.huawei.ict.entity;

import lombok.Getter;
import lombok.Setter;
import javax.persistence.*;

@Getter
@Setter
@Entity
@Table(name = "knowledge_points")
public class KnowledgePoint extends BaseEntity {

    @Column(nullable = false, length = 200)
    private String name;

    @Column(name = "mastery_rate")
    private Double masteryRate;

    @Column(name = "user_id", nullable = false)
    private Long userId;
}
